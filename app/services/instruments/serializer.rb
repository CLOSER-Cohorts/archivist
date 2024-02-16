class Instruments::Serializer
  include Pundit

  attr_accessor :datasets, :instrument, :current_user, :auth_token 

  def initialize(instrument=nil, user=nil, auth_token=nil)
    self.current_user = user
    self.instrument = instrument
    self.datasets = get_datasets
    self.auth_token = auth_token
  end

  def call
    return all unless instrument
    single
  end

  private

  def single
    i = Rails.cache.fetch("instruments/#{instrument.id}.json", version: instrument.updated_at.to_i) do
      connection = ActiveRecord::Base.connection
      sql = %|
        SELECT instruments.id, instruments.agency, instruments.version, instruments.prefix, instruments.label, instruments.slug, instruments.study, instruments.signed_off, (SELECT COUNT(*) from control_constructs WHERE control_constructs.instrument_id= #{instrument.id}) as ccs, (SELECT COUNT(*) from qv_mappings WHERE qv_mappings.instrument_id= #{instrument.id}) as qvs
        FROM instruments
        WHERE instruments.id = #{instrument.id};
            |

      i = connection.select_all(sql).to_a.first
    end

    i[:datasets] = datasets.fetch(i["id"], [])
    exports = Document.where(document_type: ['instrument_export', 'instrument_export_complete'], item_id: i["id"])
    i[:exports] = exports.order('created_at DESC').map do | doc |
      { id: doc.id, created_at: doc.created_at.strftime('%b %e %Y %I:%M %p'), url: "/instruments/#{i["id"]}/export/#{doc.id}", type: doc.document_type }
    end
    i[:export_time] = i[:exports].first.fetch(:created_at) rescue nil
    i[:export_url] = i[:exports].first.fetch(:url) rescue nil

    return i
  end

  def all
    instruments = Rails.cache.fetch('instruments.json', version: Instrument.maximum(:updated_at).to_i) do
      connection = ActiveRecord::Base.connection
      sql = %|
              SELECT instruments.id, instruments.agency, instruments.version, instruments.prefix, instruments.label, instruments.slug, instruments.study, instruments.signed_off, COUNT(DISTINCT(control_constructs.id)) as ccs, COUNT(DISTINCT(qv_mappings.id)) as qvs
              FROM instruments
              LEFT JOIN control_constructs ON control_constructs.instrument_id = instruments.id
              LEFT JOIN qv_mappings ON qv_mappings.instrument_id = instruments.id
              GROUP BY instruments.id
              ORDER BY instruments.id DESC
            |

      instruments = connection.select_all(sql).to_a
    end

    instruments = instruments.map do |i|
      i[:datasets] = datasets.fetch(i["id"], [])
      doc = Document.where(document_type: 'instrument_export', item_id: i["id"]).last rescue nil
      i[:export_time] = doc.created_at.strftime('%b %e %Y %I:%M %p') rescue nil
      i[:export_url] = "/instruments/#{i["id"]}/export/#{doc.id}?token=#{auth_token}" rescue nil
      doc = Document.where(document_type: 'instrument_export_complete', item_id: i["id"]).last rescue nil
      if doc
        i[:export_complete_time] = doc.created_at.strftime('%b %e %Y %I:%M %p')
        i[:export_complete_url] = "/instruments/#{i["id"]}/export/#{doc.id}?token=#{auth_token}"
      end
      i
    end

    instrument_ids = policy_scope(Instrument).pluck(:id)
    instruments = instruments.select{|i| instrument_ids.include?(i["id"])}

    return instruments
  end

  def get_datasets
    InstrumentsDatasets.eager_load(:dataset).all.group_by(&:instrument_id).inject({}) { |h, (instrument_id, ids)| h[instrument_id] = ids.map{|id| { id: id.dataset_id, name: id.dataset.name, instance_name: id.dataset.instance_name } }; h }
  end
end
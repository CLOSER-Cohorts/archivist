class Instruments::Serializer

  attr_accessor :datasets, :instrument

  def initialize(instrument=nil)
    self.instrument = instrument
    self.datasets = get_datasets
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
        SELECT instruments.id, instruments.agency, instruments.version, instruments.prefix, instruments.label, instruments.slug, instruments.study, (SELECT COUNT(*) from control_constructs WHERE control_constructs.instrument_id= #{instrument.id}) as ccs, (SELECT COUNT(*) from qv_mappings WHERE qv_mappings.instrument_id= #{instrument.id}) as qvs
        FROM instruments
        WHERE instruments.id = #{instrument.id};
            |

      i = connection.select_all(sql).to_a.first
    end

    i[:datasets] = datasets.fetch(i["id"], [])
    i[:export_time] = $redis.hget('export:instrument:' + i["id"].to_s, 'time') rescue nil
    i[:export_url] = $redis.hget('export:instrument:' + i["id"].to_s, 'url') rescue nil

    return i
  end

  def all
    instruments = Rails.cache.fetch('instruments.json', version: Instrument.maximum(:updated_at).to_i) do
      connection = ActiveRecord::Base.connection
      sql = %|
              SELECT instruments.id, instruments.agency, instruments.version, instruments.prefix, instruments.label, instruments.slug, instruments.study, COUNT(DISTINCT(control_constructs.id)) as ccs, COUNT(DISTINCT(qv_mappings.id)) as qvs
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
      i[:export_time] = $redis.hget('export:instrument:' + i["id"].to_s, 'time') rescue nil
      i[:export_url] = $redis.hget('export:instrument:' + i["id"].to_s, 'url') rescue nil
      i
    end

    return instruments
  end

  def get_datasets
    InstrumentsDatasets.eager_load(:dataset).all.group_by(&:instrument_id).inject({}) { |h, (instrument_id, ids)| h[instrument_id] = ids.map{|id| { id: id.dataset_id, name: id.dataset.name, instance_name: id.dataset.instance_name } }; h }
  end
end
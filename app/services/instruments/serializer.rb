class Instruments::Serializer

  attr_accessor :datasets

  def initialize
    self.datasets = get_datasets
  end

  def call
    instruments = Rails.cache.fetch('instruments.json', version: Instrument.maximum(:updated_at).to_i) do
      connection = ActiveRecord::Base.connection
      sql = %|
              SELECT instruments.id, instruments.agency, instruments.version, instruments.prefix, instruments.label, instruments.study, COUNT(DISTINCT(control_constructs.id)) as ccs, COUNT(DISTINCT(qv_mappings.id)) as qvs
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

  private

  def get_datasets
    InstrumentsDatasets.eager_load(:dataset).all.group_by(&:instrument_id).inject({}) { |h, (instrument_id, ids)| h[instrument_id] = ids.map{|id| { id: id.dataset_id, name: id.dataset.name, instance_name: id.dataset.instance_name } }; h }
  end
end
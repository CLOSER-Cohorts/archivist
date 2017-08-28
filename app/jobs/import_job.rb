module ImportJob
  class Basic
    @queue = :in_and_out

    def self.perform(document_id, options = {})
      begin
        item = yield document_id, options
        trap 'TERM' do

          item.cancel
          Resque.enqueue self.class, document_id, options

          exit 0
        end

        item.parse
      rescue => e
        Rails.logger.fatal 'Fatal error while importing'
        Rails.logger.fatal e.message
      end
    end
  end
end

class ImportJob::Instrument < ImportJob::Basic
  @queue = :in_and_out
  super do |document_id, options|
    Importers::XML::DDI::Instrument.new document_id, options
  end
end

class ImportJob::Dataset < ImportJob::Basic
  @queue = :in_and_out
  super do |document_id, options|
    Importers::XML::DDI::Dataset.new document_id, options
  end
end

class ImportJob::Mapping < ImportJob::Basic
  @queue = :in_and_out
  super do |document_id, instrument_id|
    Importers::TXT::Mapper::Mapping.new document_id, Instrument.find(instrument_id)
  end
end

class ImportJob::DV < ImportJob::Basic
  @queue = :in_and_out
  super do |document_id, dataset_id|
    Importers::TXT::Mapper::DV.new document_id, Dataset.find(dataset_id)
  end
end

class ImportJob::TopicQ < ImportJob::Basic
  @queue = :in_and_out
  super do |document_id, instrument_id|
    Importers::TXT::Mapper::TopicQ.new document_id, Instrument.find(instrument_id)
  end
end

class ImportJob::TopicV < ImportJob::Basic
  @queue = :in_and_out
  super do |document_id, dataset_id|
    Importers::TXT::Mapper::TopicV.new document_id, Dataset.find(dataset_id)
  end
end

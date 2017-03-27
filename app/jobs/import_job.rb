module ImportJob
  class Basic
    @queue = :in_and_out

    def self.perform(document_id, options = {})
      begin
        item = @importer_klass.new document_id, options
        trap 'TERM' do

          item.instrument.destroy
          Resque.enqueue self.class, document_id, options

          exit 0
        end

        item.parse
      rescue => e
        Rails.logger.fatal 'Fatal error while importing ' + @import_name
        Rails.logger.fatal e.message
      end
    end
  end
end

class ImportJob::Instrument < ImportJob::Basic
  @queue = :in_and_out
  @importer_klass = Importers::XML::DDI::Instrument
end

class ImportJob::Dataset
  @queue = :in_and_out

  def self.perform(document_id, options = {})
    begin
      im = Importers::XML::DDI::Dataset.new document_id, options
      trap 'TERM' do

        im.dataset.destroy
        Resque.enqueue ImportJob::Dataset, document_id, options

        exit 0
      end

      im.parse
    rescue => e
      Rails.logger.fatal 'Fatal error while importing dataset'
      Rails.logger.fatal e.message
    end
  end
end

class ImportJob::Mapping
  @queue = :in_and_out

  def self.perform(document_id, instrument)
    begin
      im = Importers::TXT::Mapper::Mapping.new document_id, instrument
      trap 'TERM' do

        Resque.enqueue ImportJob::Mapping, document_id, instrument

        exit 0
      end

      im.import
    rescue => e
      Rails.logger.fatal 'Fatal error while importing Q-V mapping for ' + instrument&.prefix.to_s
      Rails.logger.fatal e.message
    end
  end
end

class ImportJob::DV
  @queue = :in_and_out

  def self.perform(document_id, dataset)
  begin
    im = Importers::TXT::Mapper::DV.new document_id, dataset
    trap 'TERM' do

      Resque.enqueue ImportJob::DV, document_id, dataset

      exit 0
    end

    im.import
  rescue => e
    Rails.logger.fatal 'Fatal error while importing DV mapping for ' + dataset&.name.to_s
    Rails.logger.fatal e.message
  end
  end
end

class ImportJob::TopicQ
  @queue = :in_and_out

  def self.perform(document_id, instrument)
    begin
      im = Importers::TXT::Mapper::TopicQ.new document_id, instrument
      trap 'TERM' do

        Resque.enqueue ImportJob::TopicQ, document_id, instrument

        exit 0
      end

      im.import
    rescue => e
      Rails.logger.fatal 'Fatal error while importing topic-Q mapping for ' + instrument&.prefix.to_s
      Rails.logger.fatal e.message
    end
  end
end

class ImportJob::TopicV
  @queue = :in_and_out

  def self.perform(document_id, dataset)
  begin
    im = Importers::TXT::Mapper::TopicV.new document_id, dataset
    trap 'TERM' do

      Resque.enqueue ImportJob::TopicV, document_id, dataset

      exit 0
    end

    im.import
  rescue => e
    Rails.logger.fatal 'Fatal error while importing topic-V mapping for ' + dataset&.name.to_s
    Rails.logger.fatal e.message
  end
  end
end

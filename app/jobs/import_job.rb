module ImportJob
  class Basic
    @queue = :in_and_out

    def self.run(importer, options = {})
      begin
        trap 'TERM' do

          importer.cancel
          Resque.enqueue self.class, importer.object.id, options

          exit 0
        end

        importer.import
      rescue => e
        Rails.logger.fatal 'Fatal error while importing'
        Rails.logger.fatal e.message
      end
    end
  end
end

class ImportJob::Instrument < ImportJob::Basic
  @queue = :in_and_out
  def self.perform(document_id, options = {})
    run(Importers::XML::DDI::Instrument.new(document_id, options),options)
  end
end

class ImportJob::Dataset < ImportJob::Basic
  @queue = :in_and_out
  def self.perform(document_id, options = {})
    run(Importers::XML::DDI::Dataset.new(document_id,options), options)
  end
end

class ImportJob::Mapping < ImportJob::Basic
  @queue = :in_and_out
  def self.perform(document_id, options = {})
    run(Importers::TXT::Mapper::Mapping.new(document_id, options), options)
  end
end

class ImportJob::DV < ImportJob::Basic
  @queue = :in_and_out
  def self.perform(document_id, options = {})
    run(Importers::TXT::Mapper::DV.new(document_id, options), options)
  end
end

class ImportJob::TopicQ < ImportJob::Basic
  @queue = :in_and_out
  def self.perform(document_id, options = {})
    run(Importers::TXT::Mapper::TopicQ.new(document_id, options), options)
  end
end

class ImportJob::TopicV < ImportJob::Basic
  @queue = :in_and_out
  def self.perform(document_id, options = {})
    run(Importers::TXT::Mapper::TopicV.new(document_id, options), options)
  end
end
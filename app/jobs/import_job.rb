module ImportJob
end

class ImportJob::Instrument
  @queue = :in_and_out

  def self.perform(document_id, options = {})
    begin
      im = XML::CADDIES::Importer.new document_id, options
      trap 'TERM' do

        im.instrument.destroy
        Resque.enqueue ImportJob::Instrument, document_i, options

        exit 0
      end

      im.parse
    rescue => e
      Rails.logger.fatal "Fatal error while importing instrument"
      Rails.logger.fatal e.message
    end
  end
end

class ImportJob::Dataset
  @queue = :in_and_out

  def self.perform(document_id, options = {})
    begin
      im = XML::Sledgehammer::Importer.new document_id, options
      trap 'TERM' do

        im.dataset.destroy
        Resque.enqueue ImportJob::Dataset, document_i, options

        exit 0
      end

      im.parse
    rescue => e
      Rails.logger.fatal "Fatal error while importing dataset"
      Rails.logger.fatal e.message
    end
  end
end
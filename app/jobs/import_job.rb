class ImportJob
  @queue = :in_and_out

  def self.perform(document_id, options = {})
    begin
      im = XML::CADDIES::Importer.new document_id, options
      trap 'TERM' do

        im.instrument.destroy
        Resque.enqueue ImportJob, document_i, options

        exit 0
      end

      Rails.logger = Logger.new('C:\CLOSER\Code\archivist\worker.log')
      Rails.logger.level = Logger::DEBUG
      im.parse
      puts "E"
    rescue => e
      Rails.logger.fatal "Fatal error while importing"
      Rails.logger.fatal e
    end
  end
end
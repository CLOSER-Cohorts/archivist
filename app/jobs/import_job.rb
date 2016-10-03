class ImportJob
  @queue = :in_and_out

  def self.perform document_id
    begin
      im = XML::CADDIES::Importer.new document_id

      trap 'TERM' do

        im.instrument.destroy
        Resque.enqueue ImportJob, document_id

        exit 0
      end

      im.parse
    rescue => e
      Rails.logger.fatal e
    end
  end
end
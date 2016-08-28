class ImportJob
  @queue = :in_and_out

  def self.perform filepath
    begin
      im = XML::CADDIES::Importer.new filepath

      trap 'TERM' do

        im.instrument.destroy
        Resque.enqueue ImportJob, filepath

        exit 0
      end

      im.parse
    rescue => e
      Rails.logger.fatal e
    end
  end
end
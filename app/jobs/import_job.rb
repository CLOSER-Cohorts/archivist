class ImportJob
  @queue = :in_and_out

  def self.perform filepath
    begin
      im = XML::CADDIES::Importer.new filepath
      im.parse
    rescue => e
      Rails.logger.fatal e
    end
  end
end
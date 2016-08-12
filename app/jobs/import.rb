class Import
  @queue = :in_and_out

  def self.perform filepath
    im = XML::CADDIES::Importer.new filepath
    im.parse
  end
end
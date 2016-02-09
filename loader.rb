Dir.chdir '/Users/williampoynter/Downloads/bundles'
folders = Dir.entries(".").reject {|x| x.first == "."}

folders.each do |folder|

  if File.exist? folder + '/ddi.xml'

    im = XML::Importer.new(folder + '/ddi.xml')
    im.parse

  end

end

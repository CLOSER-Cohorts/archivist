def export_instrument(id)
  exp = XML::DDI::Exporter.new
  exp.add_root_attributes

  i = Instrument.find id
  exp.export_instrument i
  exp.build_rp
  exp.build_iis
  exp.build_cs
  exp.build_cls

  FileUtils.mkdir_p Rails.root.join('tmp', 'exports')
  f = File.new 'tmp/exports/' + i.prefix + '.xml', "w"
  f.write(exp.doc.to_xml)
  f.close
end

desc 'Export all instruments'
task :export_instruments => :environment do
  Parallel.each Instrument.all, :in_processes => 8 do |i|
    @reconnected ||= Instrument.connection.reconnect! || true
    export_instrument(i.id)
  end
end
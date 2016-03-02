desc 'Export instrument'
task :export_instruments => :environment do
  exp = XML::DDI::Exporter.new "3.2"
  exp.add_root_attributes

  i = Instrument.find 66
  exp.export_instrument i
  exp.build_rp
  exp.build_iis
  exp.build_cs
  exp.build_cls

  f = File.new "out.xml", "w"
  f.write(exp.doc.to_xml)
  f.close
end
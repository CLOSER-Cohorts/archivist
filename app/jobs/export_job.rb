class ExportJob
  @queue = :in_and_out

  def self.perform id
    begin
      exp = Exporters::XML::DDI::Instrument.new
      exp.add_root_attributes
      i = Instrument.find(id)
      exp.export_instrument i

      exp.build_rp
      exp.build_iis
      exp.build_cs
      exp.build_cls
      exp.build_qis
      exp.build_qgs
      exp.build_is
      exp.build_ccs

      d = Document.new
      d.filename = i.prefix + '.xml'
      d.content_type = 'text/xml'
      d.file_contents = exp.doc.to_xml(&:no_empty_tags)
      d.md5_hash = Digest::MD5.hexdigest d.file_contents
      d.item = i
      d.save!
    rescue => e
      Rails.logger.fatal 'Job failed.'
      Rails.logger.fatal e
      Rails.logger.fatal e.backtrace
    end
  end
end
module ExportJob; end

class ExportJob::Instrument
  @queue = :in_and_out

  def self.perform(id)
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
      d.save!
      i.add_export_document d
    rescue => e
      Rails.logger.fatal 'Job failed.'
      Rails.logger.fatal e
      Rails.logger.fatal e.backtrace
    end
  end
end

class ExportJob::Dataset
  @queue = :in_and_out

  def self.perform(id)
    begin
      exp = Exporters::XML::DDI::Dataset.new

      dataset = Dataset.find(id)
      exp.run dataset

      d = Document.new
      d.filename = dataset.filename
      d.content_type = 'text/xml'
      d.file_contents = exp.doc.to_xml(&:no_empty_tags)
      d.md5_hash = Digest::MD5.hexdigest d.file_contents
      d.item = dataset
      d.save_or_get
    rescue => e
      Rails.logger.fatal 'Job failed.'
      Rails.logger.fatal e
      Rails.logger.fatal e.backtrace
    end
  end
end
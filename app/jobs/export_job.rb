class ExportJob
  @queue = :in_and_out

  def self.perform id
    begin
      exp = XML::DDI::Exporter.new
      exp.add_root_attributes
      filename = exp.run Instrument.find(id)
      obj = $s3_bucket.object filename.basename.to_s
      obj.upload_file filename.to_s, acl:'public-read'
      $redis.hset 'export:instruments', id, obj.public_url.to_s
    rescue => e
      Rails.logger.fatal e
    end
  end
end
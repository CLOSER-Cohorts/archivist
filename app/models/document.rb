class Document < ApplicationRecord
  belongs_to :item, polymorphic: true

  def initialize(params={})
    file = params.delete :file
    super
    if file.is_a? ActionDispatch::Http::UploadedFile
      self.filename       = sanitize_filename file.path
      self.content_type   = file.content_type
      self.file_contents  = file.read
      self.md5_hash       = Digest::MD5.hexdigest self.file_contents
    elsif file.is_a? File
      self.filename       = sanitize_filename file.original_filename
      self.file_contents  = file.read
      self.md5_hash       = Digest::MD5.hexdigest self.file_contents
    end
  end

  def save_or_get
    begin
      self.save!
    rescue ActiveRecord::RecordNotUnique => e
      self.id = Document.find_by_md5_hash(self.md5_hash).id
    end
  end

  private
  def sanitize_filename(filename)
    File.basename(filename)
  end
end
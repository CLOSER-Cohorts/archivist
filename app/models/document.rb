class Document < ApplicationRecord
  belongs_to :item, polymorphic: true

  def initialize(params={})
    file = params.delete :file
    super
    if file.is_a? ActionDispatch::Http::UploadedFile
      self.filename       = sanitize_filename file.original_filename
      self.content_type   = file.content_type
      self.file_contents  = file.read
      self.md5_hash       = Digest::MD5.hexdigest self.file_contents
    elsif file.is_a? File
      self.filename       = sanitize_filename file.path
      self.file_contents  = file.read
      self.md5_hash       = Digest::MD5.hexdigest self.file_contents
    elsif file.is_a? String # i.e. comes from a base encoding
      self.filename       = "mapping_#{Devise.friendly_token}.txt"
      self.file_contents  = file
      self.md5_hash       = Digest::MD5.hexdigest file
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

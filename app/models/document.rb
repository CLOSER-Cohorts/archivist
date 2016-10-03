class Document < ApplicationRecord
  belongs_to :item, polymorphic: true

  def initialize(params={})
    file = params.delete :file
    super
    if file
      self.filename       = sanitize_filename file.original_filename
      self.content_type   = file.content_type
      self.file_contents  = file.read
      self.md5_hash       = Digest::MD5.hexdigest self.file_contents
    end
  end

  private
  def sanitize_filename(filename)
    File.basename(filename)
  end
end
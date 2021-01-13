# Stores documents into the database
#
# Instead of a shared file store between web server nodes, Archivist
# makes use of the database as files are not accessed frequently
# enough to cause performance issues.
#
# === Properties
# * filename
# * content_type
# * file_contents
# * md5_hash
class Document < ApplicationRecord
  # Each Document can belong to any other database model
  belongs_to :item, polymorphic: true

  # Creates a new Document
  #
  # @param [Hash] params Parameters for creating a new Document
  # @return [Document]
  def initialize(params={})
    file = params.try(:delete, :file)
    super
    if file.is_a? ActionDispatch::Http::UploadedFile
      self.filename = sanitize_filename file.original_filename
      self.content_type = file.content_type
      self.file_contents = file.read
      self.md5_hash = Digest::MD5.hexdigest self.file_contents
    elsif file.is_a? File
      self.filename = sanitize_filename file.path
      self.file_contents = file.read
      self.md5_hash = Digest::MD5.hexdigest self.file_contents
    elsif file.is_a? String # i.e. comes from a base encoding
      self.filename = Digest::MD5.hexdigest(Time.now.to_s) + '.txt'
      self.file_contents = file
      self.md5_hash = Digest::MD5.hexdigest file
    end
  end

  # Either save the new Document or if the md5_hash has already been used
  # return the Document from the database
  #
  # @return [Document]
  def save_or_get
    begin
      self.save!
    rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
      self.id = Document.find_by_md5_hash(self.md5_hash).id
    end
  end

  private # Private methods

  # Prepare the filename for saving
  def sanitize_filename(filename)
    File.basename(filename)
  end
end

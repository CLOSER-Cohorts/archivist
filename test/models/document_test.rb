require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  test 'document created from string' do
    test_string = 'test contents of file'
    d = Document.new file: test_string
    assert_equal test_string, d.file_contents
  end
end

require 'test_helper'

class ImportTest < ActiveSupport::TestCase
  setup do
    @import = create(:import)
  end

  test "belongs to an dataset" do
    assert_kind_of Dataset, @import.dataset
  end
end

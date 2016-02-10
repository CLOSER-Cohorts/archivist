require 'test_helper'

class InstrumentTest < ActiveSupport::TestCase
  setup do
    @instrument = instruments :one
  end

  test "has many categories" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @instrument.categories
  end

  test "has many code lists" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @instrument.code_lists
  end

  test "has many loops" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @instrument.cc_loops
  end

  test "has many conditions" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @instrument.cc_conditions
  end

  test "has many sequences" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @instrument.cc_sequences
  end

  test "has many statements" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @instrument.cc_statements
  end

  test "has many questions" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @instrument.cc_questions
  end

  test "has many instructions" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @instrument.instructions
  end

  test "has many question items" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @instrument.question_items
  end

  test "has many question grids" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @instrument.question_grids
  end

  test "has many datetimes" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @instrument.response_domain_datetimes
  end

  test "has many numerics" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @instrument.response_domain_numerics
  end

  test "has many texts" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @instrument.response_domain_texts
  end

  test "has many response units" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @instrument.response_units
  end
end

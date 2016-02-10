require 'test_helper'

class VariableTest < ActiveSupport::TestCase
  setup do
    @variable = variables :one
  end

  test "belongs to dataset" do
    assert_kind_of Dataset, @variable.dataset
  end

  test "has many questions" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @variable.questions
  end

  test "has many sources" do
    assert_kind_of Array, @variable.sources
  end

  test "has many source variables" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @variable.src_variables
  end

  test "has many derived variables" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @variable.der_variables
  end

  test "has one topic" do
    assert_kind_of Topic, @variable.topic
  end
end

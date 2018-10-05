require 'test_helper'

class CcStatementTest < ActiveSupport::TestCase
  setup do
    @cc_statement = cc_statements :CcStatement_1
  end

  test "belongs to an instrument" do
    assert_kind_of Instrument, @cc_statement.instrument
  end

  test "can read parent construct" do
    unless @cc_statement.parent.nil?
      assert_kind_of ParentalConstruct, @cc_statement.parent
    else
      assert ParentalConstruct, nil
    end
  end

  test "when construct parent is 'nil'" do
    @cc_statement.parent = nil
    unless @cc_statement.parent.nil?
      assert_kind_of ParentalConstruct, @cc_statement.parent
    else
      assert ParentalConstruct, nil
    end
  end

  test "set a new parent" do
    seq = @cc_statement.instrument.cc_sequences.create
    @cc_statement.parent = seq
    assert_equal @cc_statement.parent, seq
  end
end

require 'test_helper'

class CcStatementTest < ActiveSupport::TestCase
  setup do
    @cc_statement = cc_statements :one
  end

  test "belongs to an instrument" do
    assert_kind_of Instrument, @cc_statement.instrument
  end

  test "has one cc" do
    assert_kind_of ControlConstruct, @cc_statement.cc
  end

  test "can read parent construct" do
    assert_kind_of Construct, @cc_statement.parent
  end

  test "set a new parent" do
    seq = @cc_statement.instrument.cc_sequences.create
    @cc_statement.parent = seq
    assert_equal @cc_statement.parent, seq
  end
end

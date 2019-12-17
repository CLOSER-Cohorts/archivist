require 'test_helper'

class Instruments::ControlConstructUpdaterTest < ActiveSupport::TestCase
  setup do
    @instrument = FactoryBot.create(:instrument, study: 'uk.alspac')
    @top_sequence = FactoryBot.create(:cc_sequence, instrument: @instrument)
    @secondary_sequence = FactoryBot.create(:cc_sequence, instrument: @instrument, parent: @top_sequence, position: 1)
    @cc_question = FactoryBot.create(:cc_question, instrument: @instrument, parent: @top_sequence, position: 2)
  end

  describe ".call" do
    it "should record the order of control constructs" do
      updates_array = [
        {id: @cc_question, type: 'question', parent: { id: @secondary_sequence.id, type: 'sequence'}, position: 1, branch: 1}
      ]
      Instruments::ControlConstructUpdater.new(@instrument, updates_array).call
      assert_equal(@cc_question.reload.parent, @secondary_sequence)
    end
    it "should ignore any record without all the keys" do
      updates_array = [
        {id: @cc_question, type: 'question', parent: { id: @secondary_sequence.id, type: 'sequence'}, position: 1}
      ]
      Instruments::ControlConstructUpdater.new(@instrument, updates_array).call
      assert_equal(@cc_question.reload.parent, @top_sequence)
    end
  end
end

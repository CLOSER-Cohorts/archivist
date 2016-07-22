require 'test_helper'

class CcSequencesControllerTest < ActionController::TestCase
  setup do
    @user = users :User_1
    sign_in @user
    @cc_sequence = cc_sequences(:CcSequence_6)
    @instrument = instruments(:Instrument_1)
  end

  test "should get index" do
    get :index, format: :json, instrument_id: @instrument.id
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create cc_sequence" do
    assert_difference('CcSequence.count') do
      post :create, format: :json,
          instrument_id: @instrument.id,
          literal: @cc_sequence.literal,
          type: 'sequence',
          parent: {
              id: @instrument.cc_sequences.first.id,
              type: 'sequence'
          }
    end

    assert_response :success
  end

  test "should show cc_sequence" do
    get :show, id: @cc_sequence, format: :json, instrument_id: @instrument.id
    assert_response :success
  end

  test "should update cc_sequence" do
    patch :update, format: :json, instrument_id: @instrument.id, id: @cc_sequence, cc_sequence: {literal: @cc_sequence.literal}
    assert_response :success
  end

  test "should destroy cc_sequence" do
    assert_difference('CcSequence.count', -1) do
      delete :destroy, format: :json, instrument_id: @instrument.id, id: @cc_sequence
    end

    assert_response :success
  end
end

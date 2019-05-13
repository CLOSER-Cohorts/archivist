require 'test_helper'

class CcSequencesControllerTest < ActionController::TestCase
  setup do
    @user = users :User_1
    sign_in @user
    @cc_sequence = cc_sequences(:CcSequence_6)
    @instrument = instruments(:Instrument_1)
  end

  test "should get index" do
    get :index, format: :json, params: { instrument_id: @instrument.id }
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create cc_sequence" do
    assert_difference('CcSequence.count') do
      # puts '----- BEFORE -----'
      # puts CcSequence.count
      post :create, format: :json,
      params: {
        instrument_id: @instrument.id,
        cc_sequence: {
          id: 629,
          literal: nil,
          label: "New Test Label",
          parent_id: @instrument.cc_sequences.first.id,
          parent_type: 'CcSequence'
        }
      }
    end
    # puts '----- AFTER -----'
    # puts CcSequence.count
    # puts CcSequence.last.id
    # puts CcSequence.last.label
    # puts CcSequence.last.created_at
    assert_response :success
  end

  test "should show cc_sequence" do
    get :show, format: :json, params: { instrument_id: @instrument.id, id: @cc_sequence }
    assert_response :success
  end

  test "should update cc_sequence" do
    # puts '----- BEFORE -----'
    # puts CcSequence.find(146).label
    patch :update, format: :json, params: {
      instrument_id: @instrument.id,
      id: @cc_sequence.id,
      cc_sequence: {
        label: "Updated label"
      }
    }
    # puts '----- AFTER -----'
    # puts CcSequence.find(146).label
    assert_response :success
  end

  test "should destroy cc_sequence" do
    # puts '----- Before deleting count -----'
    # puts CcSequence.count
    assert_difference('CcSequence.count', -1) do
      delete :destroy, format: :json, params: { instrument_id: @instrument.id, id: @cc_sequence.id }
    end
    # puts '----- After deleting count -----'
    # puts CcSequence.count
    assert_response :success
  end
end

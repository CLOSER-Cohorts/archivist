require 'test_helper'

class CcSequencesControllerTest < ActionController::TestCase
  setup do
    @cc_sequence = cc_sequences(:one)
    @instrument = instruments(:two)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cc_sequences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cc_sequence" do
    assert_difference('CcSequence.count') do
      post :create, cc_sequence: { literal: @cc_sequence.literal, instrument_id: @instrument.id }
    end

    assert_redirected_to cc_sequence_path(assigns(:cc_sequence))
  end

  test "should show cc_sequence" do
    get :show, id: @cc_sequence
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cc_sequence
    assert_response :success
  end

  test "should update cc_sequence" do
    patch :update, id: @cc_sequence, cc_sequence: { literal: @cc_sequence.literal }
    assert_redirected_to cc_sequence_path(assigns(:cc_sequence))
  end

  test "should destroy cc_sequence" do
    assert_difference('CcSequence.count', -1) do
      delete :destroy, id: @cc_sequence
    end

    assert_redirected_to cc_sequences_path
  end
end

require 'test_helper'

class CcSequencesControllerTest < ActionController::TestCase
  setup do
    @user = users :User_1
    sign_in @user
    @cc_sequence = cc_sequences(:CcSequence_6)
    @instrument = instruments(:Instrument_1)
    ActiveRecord::Base.connection.execute('REFRESH MATERIALIZED VIEW ancestral_topic WITH DATA')
  end

  test "should get index" do
    get :index, format: :json, params: { instrument_id: @instrument.id }
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create cc_sequence" do
    assert_difference('CcSequence.count') do
      post :create, format: :json,
      params: {
        cc_sequence: {
          instrument_id: @instrument.id,
          literal: @cc_sequence.literal,
          type: 'sequence',
          parent: {
            id: @instrument.cc_sequences.first.id,
            type: 'sequence'
          }
          },
          instrument_id: @instrument.id
        }
    end

    assert_response :success
  end

  test "should show cc_sequence" do
    get :show, format: :json, params: { instrument_id: @instrument.id, id: @cc_sequence }
    assert_response :success
  end

  test "should update cc_sequence" do
    patch :update, format: :json, params: { instrument_id: @instrument.id, id: @cc_sequence, cc_sequence: {literal: @cc_sequence.literal} }
    assert_response :success
  end

  test "should destroy cc_sequence" do
    assert_difference('CcSequence.count', -1) do
      delete :destroy, format: :json, params: { instrument_id: @instrument.id, id: @cc_sequence.id }
    end

    assert_response :success
  end
end
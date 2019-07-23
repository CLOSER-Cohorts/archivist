require 'test_helper'

class CcStatementsControllerTest < ActionController::TestCase
  setup do
    @user = users :User_1
    sign_in @user
    @cc_statement = cc_statements(:CcStatement_1)
    @instrument = instruments(:Instrument_1)
  end

  test "should get index" do
    get :index, format: :json, params: { instrument_id: @instrument.id }
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create cc_statement" do
    assert_difference('CcStatement.count') do
      post :create, format: :json,
      params: {
        cc_statement: {
          instrument_id: @instrument.id,
          literal: @cc_statement.literal,
          type: 'statement',
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

  test "should show cc_statement" do
    get :show, format: :json, params: { instrument_id: @instrument.id, id: @cc_statement }
    assert_response :success
  end

  test "should update cc_statement" do
    patch :update, format: :json, params: { instrument_id: @instrument.id, id: @cc_statement, cc_statement: {literal: @cc_statement.literal, parent: {
            id: @instrument.cc_sequences.first.id,
            type: 'sequence'
          }} }
    assert_response :success

    assert_equal @cc_statement.reload.parent, @instrument.cc_sequences.first
  end

  test "should update cc_statement when parent type matches class name" do
    patch :update, format: :json, params: { instrument_id: @instrument.id, id: @cc_statement, cc_statement: {literal: @cc_statement.literal, parent: {
            id: @instrument.cc_sequences.first.id,
            type: 'CcSequence'
          }} }
    assert_response :success

    assert_equal @cc_statement.reload.parent, @instrument.cc_sequences.first
  end

  test "should destroy cc_statement" do
    assert_difference('CcStatement.count', -1) do
      delete :destroy, format: :json, params: { instrument_id: @instrument.id, id: @cc_statement.id }
    end

    assert_response :success
  end
end

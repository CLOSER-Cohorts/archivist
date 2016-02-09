require 'test_helper'

class CcStatementsControllerTest < ActionController::TestCase
  setup do
    @cc_statement = cc_statements(:one)
    @instrument = instruments(:two)
  end

  test "should get index" do
    get :index, format: :json, instrument_id: @instrument.id
    assert_response :success
    assert_not_nil assigns(:cc_statements)
  end

  test "should create cc_statement" do
    assert_difference('CcStatement.count') do
      post :create, format: :json, instrument_id: @instrument.id, cc_statement: { literal: @cc_statement.literal, instrument_id: @instrument.id }
    end

    assert_response :success
  end

  test "should show cc_statement" do
    get :show, id: @cc_statement, format: :json, instrument_id: @instrument.id
    assert_response :success
  end

  test "should update cc_statement" do
    patch :update, format: :json, instrument_id: @instrument.id, id: @cc_statement, cc_statement: { literal: @cc_statement.literal }
    assert_response :success
  end

  test "should destroy cc_statement" do
    assert_difference('CcStatement.count', -1) do
      delete :destroy, format: :json, instrument_id: @instrument.id, id: @cc_statement
    end

    assert_response :success
  end
end

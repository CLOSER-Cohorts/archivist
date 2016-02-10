require 'test_helper'

class CcConditionsControllerTest < ActionController::TestCase
  setup do
    @cc_condition = cc_conditions(:one)
    @instrument = instruments(:two)
  end

  test "should get index" do
    get :index, format: :json, instrument_id: @instrument.id
    assert_response :success
    assert_not_nil assigns(:cc_conditions)
  end

  test "should create cc_condition" do
    assert_difference('CcCondition.count') do
      post :create, format: :json, instrument_id: @instrument.id, cc_condition: {literal: @cc_condition.literal, logic: @cc_condition.logic, instrument_id: @instrument.id}
    end

    assert_response :success
  end

  test "should show cc_condition" do
    get :show, format: :json, instrument_id: @instrument.id, id: @cc_condition
    assert_response :success
  end

  test "should update cc_condition" do
    patch :update, format: :json, instrument_id: @instrument.id, id: @cc_condition, cc_condition: {literal: @cc_condition.literal, logic: @cc_condition.logic}
    assert_response :success
  end

  test "should destroy cc_condition" do
    assert_difference('CcCondition.count', -1) do
      delete :destroy, format: :json, instrument_id: @instrument.id, id: @cc_condition
    end

    assert_response :success
  end
end

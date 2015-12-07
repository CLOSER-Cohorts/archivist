require 'test_helper'

class CcConditionsControllerTest < ActionController::TestCase
  setup do
    @cc_condition = cc_conditions(:one)
    @instrument = instruments(:two)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cc_conditions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cc_condition" do
    assert_difference('CcCondition.count') do
      post :create, cc_condition: { literal: @cc_condition.literal, logic: @cc_condition.logic, instrument_id: @instrument.id }
    end

    assert_redirected_to cc_condition_path(assigns(:cc_condition))
  end

  test "should show cc_condition" do
    get :show, id: @cc_condition
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cc_condition
    assert_response :success
  end

  test "should update cc_condition" do
    patch :update, id: @cc_condition, cc_condition: { literal: @cc_condition.literal, logic: @cc_condition.logic }
    assert_redirected_to cc_condition_path(assigns(:cc_condition))
  end

  test "should destroy cc_condition" do
    assert_difference('CcCondition.count', -1) do
      delete :destroy, id: @cc_condition
    end

    assert_redirected_to cc_conditions_path
  end
end

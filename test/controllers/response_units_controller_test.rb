require 'test_helper'

class ResponseUnitsControllerTest < ActionController::TestCase
  setup do
    @response_unit = response_units(:one)
    @instrument = instruments(:two)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:response_units)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create response_unit" do
    assert_difference('ResponseUnit.count') do
      post :create, response_unit: { label: @response_unit.label, instrument_id: @instrument.id }
    end

    assert_redirected_to response_unit_path(assigns(:response_unit))
  end

  test "should show response_unit" do
    get :show, id: @response_unit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @response_unit
    assert_response :success
  end

  test "should update response_unit" do
    patch :update, id: @response_unit, response_unit: { label: @response_unit.label }
    assert_redirected_to response_unit_path(assigns(:response_unit))
  end

  test "should destroy response_unit" do
    assert_difference('ResponseUnit.count', -1) do
      delete :destroy, id: @response_unit
    end

    assert_redirected_to response_units_path
  end
end

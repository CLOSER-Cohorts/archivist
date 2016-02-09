require 'test_helper'

class ResponseUnitsControllerTest < ActionController::TestCase
  setup do
    @response_unit = response_units(:one)
    @instrument = instruments(:two)
  end

  test "should get index" do
    get :index, format: :json, instrument_id: @instrument.id
    assert_response :success
    assert_not_nil assigns(:response_units)
  end

  test "should create response_unit" do
    assert_difference('ResponseUnit.count') do
      post :create, format: :json, instrument_id: @instrument.id, response_unit: { label: @response_unit.label, instrument_id: @instrument.id }
    end

    assert_response :success
  end

  test "should show response_unit" do
    get :show, id: @response_unit, format: :json, instrument_id: @instrument.id
    assert_response :success
  end

  test "should update response_unit" do
    patch :update, format: :json, instrument_id: @instrument.id, id: @response_unit, response_unit: { label: @response_unit.label }
    assert_response :success
  end

  test "should destroy response_unit" do
    assert_difference('ResponseUnit.count', -1) do
      delete :destroy, format: :json, instrument_id: @instrument.id, id: @response_unit
    end

    assert_response :success
  end
end

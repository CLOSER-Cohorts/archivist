require 'test_helper'

class ResponseDomainNumericsControllerTest < ActionController::TestCase
  setup do
    @response_domain_numeric = response_domain_numerics(:ResponseDomainNumeric_1)
    @instrument = instruments(:Instrument_1)
  end

  test "should get index" do
    get :index, format: :json, instrument_id: @instrument.id
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create response_domain_numeric" do
    assert_difference('ResponseDomainNumeric.count') do
      post :create, format: :json, instrument_id: @instrument.id, response_domain_numeric: {label: @response_domain_numeric.label, max: @response_domain_numeric.max, min: @response_domain_numeric.min, numeric_type: @response_domain_numeric.numeric_type, instrument_id: @instrument.id}
    end

    assert_response :success
  end

  test "should show response_domain_numeric" do
    get :show, id: @response_domain_numeric, format: :json, instrument_id: @instrument.id
    assert_response :success
  end

  test "should update response_domain_numeric" do
    patch :update, format: :json, instrument_id: @instrument.id, id: @response_domain_numeric, response_domain_numeric: {label: @response_domain_numeric.label, max: @response_domain_numeric.max, min: @response_domain_numeric.min, numeric_type: @response_domain_numeric.numeric_type}
    assert_response :success
  end

  test "should destroy response_domain_numeric" do
    assert_difference('ResponseDomainNumeric.count', -1) do
      delete :destroy, format: :json, instrument_id: @instrument.id, id: @response_domain_numeric
    end

    assert_response :success
  end
end

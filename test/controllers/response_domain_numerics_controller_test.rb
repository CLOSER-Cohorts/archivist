require 'test_helper'

class ResponseDomainNumericsControllerTest < ActionController::TestCase
  setup do
    @response_domain_numeric = response_domain_numerics(:one)
    @instrument = instruments(:two)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:response_domain_numerics)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create response_domain_numeric" do
    assert_difference('ResponseDomainNumeric.count') do
      post :create, response_domain_numeric: { label: @response_domain_numeric.label, max: @response_domain_numeric.max, min: @response_domain_numeric.min, numeric_type: @response_domain_numeric.numeric_type, instrument_id: @instrument.id }
    end

    assert_redirected_to response_domain_numeric_path(assigns(:response_domain_numeric))
  end

  test "should show response_domain_numeric" do
    get :show, id: @response_domain_numeric
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @response_domain_numeric
    assert_response :success
  end

  test "should update response_domain_numeric" do
    patch :update, id: @response_domain_numeric, response_domain_numeric: { label: @response_domain_numeric.label, max: @response_domain_numeric.max, min: @response_domain_numeric.min, numeric_type: @response_domain_numeric.numeric_type }
    assert_redirected_to response_domain_numeric_path(assigns(:response_domain_numeric))
  end

  test "should destroy response_domain_numeric" do
    assert_difference('ResponseDomainNumeric.count', -1) do
      delete :destroy, id: @response_domain_numeric
    end

    assert_redirected_to response_domain_numerics_path
  end
end

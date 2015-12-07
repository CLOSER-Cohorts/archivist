require 'test_helper'

class ResponseDomainDatetimesControllerTest < ActionController::TestCase
  setup do
    @response_domain_datetime = response_domain_datetimes(:one)
    @instrument = instruments(:two)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:response_domain_datetimes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create response_domain_datetime" do
    assert_difference('ResponseDomainDatetime.count') do
      post :create, response_domain_datetime: { datetime_type: @response_domain_datetime.datetime_type, format: @response_domain_datetime.format, label: @response_domain_datetime.label, instrument_id: @instrument.id }
    end

    assert_redirected_to response_domain_datetime_path(assigns(:response_domain_datetime))
  end

  test "should show response_domain_datetime" do
    get :show, id: @response_domain_datetime
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @response_domain_datetime
    assert_response :success
  end

  test "should update response_domain_datetime" do
    patch :update, id: @response_domain_datetime, response_domain_datetime: { datetime_type: @response_domain_datetime.datetime_type, format: @response_domain_datetime.format, label: @response_domain_datetime.label }
    assert_redirected_to response_domain_datetime_path(assigns(:response_domain_datetime))
  end

  test "should destroy response_domain_datetime" do
    assert_difference('ResponseDomainDatetime.count', -1) do
      delete :destroy, id: @response_domain_datetime
    end

    assert_redirected_to response_domain_datetimes_path
  end
end

require 'test_helper'

class ResponseDomainDatetimesControllerTest < ActionController::TestCase
  setup do
    @response_domain_datetime = response_domain_datetimes(:ResponseDomainDatetime_1)
    @instrument = instruments(:Instrument_1)
  end

  test "should get index" do
    get :index, format: :json, instrument_id: @instrument.id
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create response_domain_datetime" do
    assert_difference('ResponseDomainDatetime.count') do
      post :create, format: :json, instrument_id: @instrument.id, response_domain_datetime: {datetime_type: @response_domain_datetime.datetime_type, format: @response_domain_datetime.format, label: @response_domain_datetime.label, instrument_id: @instrument.id}
    end

    assert_response :success
  end

  test "should show response_domain_datetime" do
    get :show, id: @response_domain_datetime, format: :json, instrument_id: @instrument.id
    assert_response :success
  end

  test "should update response_domain_datetime" do
    patch :update, format: :json, instrument_id: @instrument.id, id: @response_domain_datetime, response_domain_datetime: {datetime_type: @response_domain_datetime.datetime_type, format: @response_domain_datetime.format, label: @response_domain_datetime.label}
    assert_response :success
  end

  test "should destroy response_domain_datetime" do
    assert_difference('ResponseDomainDatetime.count', -1) do
      delete :destroy, format: :json, instrument_id: @instrument.id, id: @response_domain_datetime
    end

    assert_response :success
  end
end

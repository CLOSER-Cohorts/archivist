require 'test_helper'

class ResponseDomainTextsControllerTest < ActionController::TestCase
  setup do
    @response_domain_text = response_domain_texts(:ResponseDomainText_1)
    @instrument = instruments(:Instrument_1)
  end

  test "should get index" do
    get :index, format: :json, instrument_id: @instrument.id
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create response_domain_text" do
    assert_difference('ResponseDomainText.count') do
      post :create, format: :json, instrument_id: @instrument.id, response_domain_text: {label: @response_domain_text.label, maxlen: @response_domain_text.maxlen, instrument_id: @instrument.id}
    end

    assert_response :success
  end

  test "should show response_domain_text" do
    get :show, id: @response_domain_text, format: :json, instrument_id: @instrument.id
    assert_response :success
  end

  test "should update response_domain_text" do
    patch :update, format: :json, instrument_id: @instrument.id, id: @response_domain_text, response_domain_text: {label: @response_domain_text.label, maxlen: @response_domain_text.maxlen}
    assert_response :success
  end

  test "should destroy response_domain_text" do
    assert_difference('ResponseDomainText.count', -1) do
      delete :destroy, format: :json, instrument_id: @instrument.id, id: @response_domain_text
    end

    assert_response :success
  end
end

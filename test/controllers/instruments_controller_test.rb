require 'test_helper'

class InstrumentsControllerTest < ActionController::TestCase
  setup do
    @instrument = instruments(:one)
  end

  test "should get index" do
    get :index, format: :json
    assert_response :success
    assert_not_nil assigns(:instruments)
  end

  test "should create instrument" do
    assert_difference('Instrument.count') do
      post :create, format: :json, instrument: { agency: @instrument.agency, label: @instrument.label, prefix: @instrument.prefix, study: @instrument.study, version: @instrument.version }
    end

    assert_response :success
  end

  test "should show instrument" do
    get :show, format: :json, id: @instrument
    assert_response :success
  end

  test "should update instrument" do
    patch :update, format: :json, id: @instrument, instrument: { agency: @instrument.agency, label: @instrument.label, prefix: @instrument.prefix, study: @instrument.study, version: @instrument.version }
    assert_response :success
  end

  test "should destroy instrument" do
    assert_difference('Instrument.count', -1) do
      delete :destroy, format: :json, id: @instrument
    end

    assert_response :success
  end
end

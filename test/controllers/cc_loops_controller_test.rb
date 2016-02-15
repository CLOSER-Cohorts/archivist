require 'test_helper'

class CcLoopsControllerTest < ActionController::TestCase
  setup do
    @cc_loop = cc_loops(:one)
    @instrument = instruments(:one)
  end

  test "should get index" do
    get :index, format: :json, instrument_id: @instrument.id
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create cc_loop" do
    assert_difference('CcLoop.count') do
      post :create, format: :json, instrument_id: @instrument.id, cc_loop: {end_val: @cc_loop.end_val, loop_var: @cc_loop.loop_var, loop_while: @cc_loop.loop_while, start_val: @cc_loop.start_val, instrument_id: @instrument.id}
    end

    assert_response :success
  end

  test "should show cc_loop" do
    get :show, format: :json, instrument_id: @instrument.id, id: @cc_loop
    assert_response :success
  end

  test "should update cc_loop" do
    patch :update, format: :json, instrument_id: @instrument.id, id: @cc_loop, cc_loop: {end_val: @cc_loop.end_val, loop_var: @cc_loop.loop_var, loop_while: @cc_loop.loop_while, start_val: @cc_loop.start_val}
    assert_response :success
  end

  test "should destroy cc_loop" do
    assert_difference('CcLoop.count', -1) do
      delete :destroy, format: :json, instrument_id: @instrument.id, id: @cc_loop
    end

    assert_response :success
  end
end

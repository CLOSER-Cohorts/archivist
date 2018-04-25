require 'test_helper'

class CodeListsControllerTest < ActionController::TestCase
  setup do
    @user = users :User_1
    sign_in @user
    @code_list = code_lists(:CodeList_1)
    @instrument = instruments(:Instrument_1)
  end

  test "should get index" do
    get :index, format: :json, params: { instrument_id: @instrument.id }
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create code_list" do
    assert_difference('CodeList.count') do
      post :create, format: :json, params: { instrument_id: @instrument.id, code_list: {label: @code_list.label + '_i', instrument_id: @instrument.id} }
    end

    assert_response :success
  end

  test "should show code_list" do
    get :show, format: :json, params: { instrument_id: @instrument.id, id: @code_list }
    assert_response :success
  end

  test "should update code_list" do
    patch :update, format: :json, params: { instrument_id: @instrument.id, id: @code_list, code_list: {label: @code_list.label} }
    assert_response :success
  end

  test "should destroy code_list" do
    assert_difference('CodeList.count', -1) do
      delete :destroy, format: :json, params: { instrument_id: @instrument.id, id: @code_list }
    end

    assert_response :success
  end
end

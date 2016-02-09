require 'test_helper'

class CodeListsControllerTest < ActionController::TestCase
  setup do
    @code_list = code_lists(:one)
    @instrument = instruments(:two)
  end

  test "should get index" do
    get :index, format: :json, instrument_id: @instrument.id
    assert_response :success
    assert_not_nil assigns(:code_lists)
  end

  test "should create code_list" do
    assert_difference('CodeList.count') do
      post :create, format: :json, instrument_id: @instrument.id, code_list: { label: @code_list.label, instrument_id: @instrument.id }
    end

    assert_response :success
  end

  test "should show code_list" do
    get :show, id: @code_list, format: :json, instrument_id: @instrument.id
    assert_response :success
  end

  test "should update code_list" do
    patch :update, format: :json, instrument_id: @instrument.id, id: @code_list, code_list: { label: @code_list.label }
    assert_response :success
  end

  test "should destroy code_list" do
    assert_difference('CodeList.count', -1) do
      delete :destroy, format: :json, instrument_id: @instrument.id, id: @code_list
    end

    assert_response :success
  end
end

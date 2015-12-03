require 'test_helper'

class CodeListsControllerTest < ActionController::TestCase
  setup do
    @code_list = code_lists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:code_lists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create code_list" do
    assert_difference('CodeList.count') do
      post :create, code_list: { label: @code_list.label }
    end

    assert_redirected_to code_list_path(assigns(:code_list))
  end

  test "should show code_list" do
    get :show, id: @code_list
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @code_list
    assert_response :success
  end

  test "should update code_list" do
    patch :update, id: @code_list, code_list: { label: @code_list.label }
    assert_redirected_to code_list_path(assigns(:code_list))
  end

  test "should destroy code_list" do
    assert_difference('CodeList.count', -1) do
      delete :destroy, id: @code_list
    end

    assert_redirected_to code_lists_path
  end
end

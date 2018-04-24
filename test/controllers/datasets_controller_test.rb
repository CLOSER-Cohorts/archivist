require 'test_helper'

class DatasetsControllerTest < ActionController::TestCase
  setup do
    @user = users :User_1
    sign_in @user
    @dataset = datasets(:Dataset_1)
    @dataset2 = datasets(:Dataset_2)
  end

  test "should get index" do
    get :index, format: :json
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create dataset" do
    assert_difference('Dataset.count') do
      post :create, format: :json, params: { dataset: {name: @dataset.name} }
    end

    assert_response :success
  end

  test "should show dataset" do
    get :show, format: :json, params: { id: @dataset }
    assert_response :success
  end

  test "should update dataset" do
    patch :update, format: :json, params: { id: @dataset, dataset: {name: @dataset.name} }
    assert_response :success
  end

  test "should destroy dataset" do
    assert_difference('Dataset.count', -1) do
      delete :destroy, format: :json, params: { id: @dataset2.id }
    end

    assert_response :success
  end
end

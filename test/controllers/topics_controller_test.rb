require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  setup do
    @user = users :User_1
    sign_in @user
    @topic = topics(:Topic_2)
    @l2_topic = topics(:Topic_23)
  end

  test "should get index" do
    get :index, format: :json
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create topic" do
    assert_difference('Topic.count') do
      post :create, format: :json, topic: {code: @topic.code, name: @topic.name, parent_id: @topic.parent_id}
    end

    assert_response :success
  end

  test "should show topic" do
    get :show, id: @topic, format: :json
    assert_response :success
  end

  test "should update topic" do
    patch :update, format: :json, id: @topic, topic: {code: @topic.code, name: @topic.name, parent_id: @topic.parent_id}
    assert_response :success
  end

  test "should destroy topic" do

    assert_difference('Topic.count', -1) do
      delete :destroy, format: :json, id: @l2_topic
    end

    assert_response :success
  end
end

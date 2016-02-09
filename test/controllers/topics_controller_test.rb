require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  setup do
    @topic = topics(:one)
    @l2_topic = topics(:two)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:topics)
  end

  test "should create topic" do
    assert_difference('Topic.count') do
      post :create, topic: { code: @topic.code, name: @topic.name, parent_id: @topic.parent_id }
    end

    assert_redirected_to topic_path(assigns(:topic))
  end

  test "should show topic" do
    get :show, id: @topic, format: :json
    assert_response :success
  end

  test "should update topic" do
    patch :update, id: @topic, topic: { code: @topic.code, name: @topic.name, parent_id: @topic.parent_id }
    assert_redirected_to topic_path(assigns(:topic))
  end

  test "should destroy topic" do
    
    assert_difference('Topic.count', -1) do
      delete :destroy, id: @l2_topic
    end

    assert_redirected_to topics_path
  end
end

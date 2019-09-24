require 'test_helper'

class VariablesControllerTest < ActionController::TestCase
  setup do
    @user = users :User_1
    sign_in @user
    @variable = variables(:Variable_1)
    @dataset = datasets(:Dataset_1)
  end

  test "should get index" do
    get :index, format: :json, params: { dataset_id: @dataset.id }
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create variable" do
    assert_difference('Variable.count') do
      post :create, format: :json, params: { dataset_id: @dataset.id, variable: {dataset_id: @variable.dataset_id, label: @variable.label, name: 'v'+@variable.name, var_type: @variable.var_type} }
    end

    assert_response :success
  end

  test "should show variable" do
    get :show, format: :json, params: { dataset_id: @dataset.id, id: @variable }
    assert_response :success
  end

  test "should update variable" do
    patch :update, format: :json, params: { dataset_id: @dataset.id, id: @variable, variable: {dataset_id: @variable.dataset_id, label: @variable.label, name: @variable.name, var_type: @variable.var_type} }
    assert_response :success
  end

  test "should destroy variable" do
    assert_difference('Variable.count', -1) do
      delete :destroy, format: :json, params: { id: @variable, dataset_id: @dataset.id }
    end

    assert_response :success
  end

  test "should show tv.txt" do
    dataset = FactoryBot.create(:dataset)
    variable = FactoryBot.create(:variable, dataset: dataset)
    topic = FactoryBot.create(:topic)
    variable.topic = topic
    get :tv, format: :txt, params: { dataset_id: dataset.id }
    assert_response :success
    parsed_response = response.body.split("\n").map{|line| line.split("\t")}
    assert_equal parsed_response.first, [dataset.instance_name, variable.name, variable.fully_resolved_topic_code]
  end
end

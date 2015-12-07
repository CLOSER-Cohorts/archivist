require 'test_helper'

class QuestionItemsControllerTest < ActionController::TestCase
  setup do
    @question_item = question_items(:one)
    @instrument = instruments(:two)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:question_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create question_item" do
    assert_difference('QuestionItem.count') do
      post :create, question_item: { instruction_id: @question_item.instruction_id, label: @question_item.label, literal: @question_item.literal, instrument_id: @instrument.id }
    end

    assert_redirected_to question_item_path(assigns(:question_item))
  end

  test "should show question_item" do
    get :show, id: @question_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @question_item
    assert_response :success
  end

  test "should update question_item" do
    patch :update, id: @question_item, question_item: { instruction_id: @question_item.instruction_id, label: @question_item.label, literal: @question_item.literal }
    assert_redirected_to question_item_path(assigns(:question_item))
  end

  test "should destroy question_item" do
    assert_difference('QuestionItem.count', -1) do
      delete :destroy, id: @question_item
    end

    assert_redirected_to question_items_path
  end
end

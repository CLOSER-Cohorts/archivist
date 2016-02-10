require 'test_helper'

class QuestionItemsControllerTest < ActionController::TestCase
  setup do
    @question_item = question_items(:one)
    @instrument = instruments(:two)
  end

  test "should get index" do
    get :index, format: :json, instrument_id: @instrument.id
    assert_response :success
    assert_not_nil assigns(:question_items)
  end

  test "should create question_item" do
    assert_difference('QuestionItem.count') do
      post :create, format: :json, instrument_id: @instrument.id, question_item: {instruction_id: @question_item.instruction_id, label: @question_item.label, literal: @question_item.literal, instrument_id: @instrument.id}
    end

    assert_response :success
  end

  test "should show question_item" do
    get :show, id: @question_item, format: :json, instrument_id: @instrument.id
    assert_response :success
  end

  test "should update question_item" do
    patch :update, format: :json, instrument_id: @instrument.id, id: @question_item, question_item: {instruction_id: @question_item.instruction_id, label: @question_item.label, literal: @question_item.literal}
    assert_response :success
  end

  test "should destroy question_item" do
    assert_difference('QuestionItem.count', -1) do
      delete :destroy, format: :json, instrument_id: @instrument.id, id: @question_item
    end

    assert_response :success
  end
end

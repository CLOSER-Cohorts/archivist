require 'test_helper'

class QuestionItemsControllerTest < ActionController::TestCase
  setup do
    @user = users :User_1
    sign_in @user
    @question_item = question_items(:QuestionItem_145)
    @instrument = instruments(:Instrument_1)
  end

  test "should get index" do
    get :index, format: :json, params: { instrument_id: @instrument.id }
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create question_item" do
    assert_difference('QuestionItem.count') do
      post :create, format: :json, params: {
        instrument_id: @instrument.id,
        question_item: {
          instruction_id: @question_item.instruction_id,
          label: @question_item.label + '_i',
          literal: @question_item.literal,
          instrument_id: @instrument.id
        }
      }
    end

    assert_response :success
  end

  test "should show question_item" do
    get :show, format: :json, params: { instrument_id: @instrument.id, id: @question_item }
    assert_response :success
  end

  test "should update question_item" do
    patch :update, format: :json, params: { instrument_id: @instrument.id, id: @question_item, question_item: {instruction_id: @question_item.instruction_id, label: @question_item.label, literal: @question_item.literal} }
    assert_response :success
  end

  test "should destroy question_item" do
    assert_difference('QuestionItem.count', -1) do
      delete :destroy, format: :json, params: { instrument_id: @instrument.id, id: @question_item }
    end

    assert_response :success
  end
end

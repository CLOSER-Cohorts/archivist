require 'test_helper'

class CcQuestionsControllerTest < ActionController::TestCase
  setup do
    @cc_question = cc_questions(:one)
    @instrument = instruments(:two)
  end

  test "should get index" do
    get :index, format: :json
    assert_response :success
    assert_not_nil assigns(:cc_questions)
  end

  test "should create cc_question" do
    assert_difference('CcQuestion.count') do
      post :create, format: :json, cc_question: {
        question_id: @cc_question.question_id, 
        question_type: @cc_question.question_type, 
        instrument_id: @instrument.id,
        response_unit_id: @cc_question.response_unit.id }
    end

    assert_response :success
  end

  test "should show cc_question" do
    get :show, format: :json, id: @cc_question
    assert_response :success
  end

  test "should update cc_question" do
    patch :update, format: :json, id: @cc_question, cc_question: { question_id: @cc_question.question_id, question_type: @cc_question.question_type }
    assert_response :success
  end

  test "should destroy cc_question" do
    assert_difference('CcQuestion.count', -1) do
      delete :destroy, format: :json, id: @cc_question
    end

    assert_response :success
  end
end

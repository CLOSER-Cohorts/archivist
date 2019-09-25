require 'test_helper'

class CcQuestionsControllerTest < ActionController::TestCase
  setup do
    @user = users :User_1
    sign_in @user
    @cc_question = cc_questions(:CcQuestion_4)
    @instrument = instruments(:Instrument_1)
  end

  test "should get index" do
    get :index, format: :json, params: { instrument_id: @instrument.id }
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  # test "should create cc_question" do
  #   assert_difference('CcQuestion.count') do
  #     post :create, format: :json,
  #     params: {
  #       instrument_id: @instrument.id,
  #       cc_question: {
  #         instrument_id: @instrument.id,
  #         question_id: @cc_question.question_id,
  #         question_type: @cc_question.question_type,
  #         response_unit_id: @cc_question.response_unit.id,
  #         type: 'question',
  #         parent: {
  #           id: @cc_question.parent.id,
  #           type: 'sequence'
  #         }
  #       }
  #     }
  #   end
  #   assert_response :success
  # end

  test "should show cc_question" do
    get :show, format: :json, params: { instrument_id: @instrument.id, id: @cc_question }
    assert_response :success
  end

  test "should update cc_question" do
    patch :update, format: :json, params: { instrument_id: @instrument.id, id: @cc_question, cc_question: {question_id: @cc_question.question_id, question_type: @cc_question.question_type, parent: {
            id: @instrument.cc_sequences.first.id,
            type: 'sequence'
          }} }
    assert_response :success

    assert_equal @cc_question.reload.parent, @instrument.cc_sequences.first
  end

  test "should update cc_question when parent type matches class name" do
    patch :update, format: :json, params: { instrument_id: @instrument.id, id: @cc_question, cc_question: {question_id: @cc_question.question_id, question_type: @cc_question.question_type, parent: {
            id: @instrument.cc_sequences.first.id,
            type: 'CcSequence'
          }} }
    assert_response :success

    assert_equal @cc_question.reload.parent, @instrument.cc_sequences.first
  end

  test "should destroy cc_question" do
    assert_difference('CcQuestion.count', -1) do
      delete :destroy, format: :json, params: { instrument_id: @instrument.id, id: @cc_question }
    end

    assert_response :success
  end

  test "should show tq.txt" do
    instrument = FactoryBot.create(:instrument)
    cc_question = FactoryBot.create(:cc_question, instrument: instrument, label: 'qc_abc_123')
    topic = FactoryBot.create(:topic)
    cc_question.topic = topic
    get :tq, format: :txt, params: { instrument_id: instrument.id }
    assert_response :success
    parsed_response = response.body.split("\n").map{|line| line.split("\t")}
    assert_equal parsed_response.first, [cc_question.control_construct_scheme, cc_question.label, cc_question.fully_resolved_topic_code]
  end
end

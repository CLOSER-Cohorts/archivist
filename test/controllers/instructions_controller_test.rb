require 'test_helper'

class InstructionsControllerTest < ActionController::TestCase
  setup do
    @user = users :User_1
    sign_in @user
    @instruction = instructions(:Instruction_1)
    @instrument = instruments(:Instrument_1)
  end

  test "should get index" do
    get :index, format: :json, instrument_id: @instrument.id
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create instruction" do
    assert_difference('Instruction.count') do
      post :create, format: :json, instrument_id: @instrument.id, instruction: {text: @instruction.text, instrument_id: @instrument.id}
    end

    assert_response :success
  end

  test "should show instruction" do
    get :show, format: :json, instrument_id: @instrument.id, id: @instruction
    assert_response :success
  end

  test "should update instruction" do
    patch :update, format: :json, instrument_id: @instrument.id, id: @instruction, instruction: {text: @instruction.text}
    assert_response :success
  end

  test "should destroy instruction" do
    assert_difference('Instruction.count', -1) do
      delete :destroy, format: :json, instrument_id: @instrument.id, id: @instruction
    end
    assert_response :success
  end
end

require 'test_helper'

class QuestionGridsControllerTest < ActionController::TestCase
  setup do
    @question_grid = question_grids(:QuestionGrid_1)
    @instrument = instruments(:Instrument_1)
    @xaxis = code_lists(:CodeList_11)
    @yaxis = code_lists(:CodeList_14)
  end

  test "should get index" do
    get :index, format: :json, instrument_id: @instrument.id
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create question_grid" do
    assert_difference('QuestionGrid.count') do
      post :create, format: :json, instrument_id: @instrument.id, question_grid: {corner_label: @question_grid.corner_label, horizontal_code_list_id: @xaxis.id, instruction_id: @question_grid.instruction_id, label: @question_grid.label, literal: @question_grid.literal, roster_label: @question_grid.roster_label, roster_rows: @question_grid.roster_rows, vertical_code_list_id: @yaxis.id, instrument_id: @instrument.id}
    end

    assert_response :success
  end

  test "should show question_grid" do
    get :show, id: @question_grid, format: :json, instrument_id: @instrument.id
    assert_response :success
  end

  test "should update question_grid" do
    patch :update, format: :json, instrument_id: @instrument.id, id: @question_grid, question_grid: {corner_label: @question_grid.corner_label, horizontal_code_list_id: @question_grid.horizontal_code_list_id, instruction_id: @question_grid.instruction_id, label: @question_grid.label, literal: @question_grid.literal, roster_label: @question_grid.roster_label, roster_rows: @question_grid.roster_rows, vertical_code_list_id: @question_grid.vertical_code_list_id}
    assert_response :success
  end

  test "should destroy question_grid" do
    assert_difference('QuestionGrid.count', -1) do
      delete :destroy, format: :json, instrument_id: @instrument.id, id: @question_grid
    end

    assert_response :success
  end
end

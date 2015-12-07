require 'test_helper'

class QuestionGridsControllerTest < ActionController::TestCase
  setup do
    @question_grid = question_grids(:one)
    @instrument = instruments(:two)
    @xaxis = code_lists(:axisx)
    @yaxis = code_lists(:axisy)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:question_grids)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create question_grid" do
    assert_difference('QuestionGrid.count') do
      post :create, question_grid: { corner_label: @question_grid.corner_label, horizontal_code_list_id: @xaxis.id, instruction_id: @question_grid.instruction_id, label: @question_grid.label, literal: @question_grid.literal, roster_label: @question_grid.roster_label, roster_rows: @question_grid.roster_rows, vertical_code_list_id: @yaxis.id, instrument_id: @instrument.id }
    end

    assert_redirected_to question_grid_path(assigns(:question_grid))
  end

  test "should show question_grid" do
    get :show, id: @question_grid
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @question_grid
    assert_response :success
  end

  test "should update question_grid" do
    patch :update, id: @question_grid, question_grid: { corner_label: @question_grid.corner_label, horizontal_code_list_id: @question_grid.horizontal_code_list_id, instruction_id: @question_grid.instruction_id, label: @question_grid.label, literal: @question_grid.literal, roster_label: @question_grid.roster_label, roster_rows: @question_grid.roster_rows, vertical_code_list_id: @question_grid.vertical_code_list_id }
    assert_redirected_to question_grid_path(assigns(:question_grid))
  end

  test "should destroy question_grid" do
    assert_difference('QuestionGrid.count', -1) do
      delete :destroy, id: @question_grid
    end

    assert_redirected_to question_grids_path
  end
end

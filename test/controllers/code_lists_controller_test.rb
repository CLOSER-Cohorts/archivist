require 'test_helper'

class CodeListsControllerTest < ActionController::TestCase
  setup do
    @user = users :User_1
    sign_in @user
    @code_list = code_lists(:CodeList_1)
    @instrument = instruments(:Instrument_1)
  end

  test "should get index" do
    get :index, format: :json, params: { instrument_id: @instrument.id }
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create code_list" do
    assert_difference('CodeList.count') do
      post :create, format: :json, params: { instrument_id: @instrument.id, code_list: {label: @code_list.label + '_i', instrument_id: @instrument.id} }
    end

    assert_response :success
  end

  test "should create with the min_responses and max_responses" do
    post :create, format: :json, params: { instrument_id: @instrument.id, rd: true, min_responses: 2, max_responses: 3, code_list: { label: @code_list.label + '_i', instrument_id: @instrument.id} }
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal json['min_responses'], 2
    assert_equal json['max_responses'], 3
  end

  test "should show code_list" do
    get :show, format: :json, params: { instrument_id: @instrument.id, id: @code_list }
    assert_response :success
  end

  test "should update code_list" do
    patch :update, format: :json, params: { instrument_id: @instrument.id, id: @code_list, code_list: {label: @code_list.label} }
    assert_response :success
  end

  test "should give errors if trying to update code_list with invalid params" do
    patch :update, format: :json, params: { instrument_id: @instrument.id, id: @code_list, code_list: {label: @code_list.label, codes: [{ id: @code_list.codes.first.id, category_id: 5263, value: "1", label: '', order: 1}] }}
    assert_response :unprocessable_entity
  end

  test "should remove existing codes if not found in the codes parameters" do
    code_to_be_deleted = @code_list.codes.last
    patch :update, format: :json, params: { instrument_id: @instrument.id, id: @code_list, code_list: {label: @code_list.label, codes: [{ id: @code_list.codes.first.id, category_id: 5263, value: "1", label: 'New Label', order: 1}] }}
    assert_response :success
    refute_includes @code_list.reload.codes, code_to_be_deleted
  end

  test "should update with the min_responses and max_responses" do
    patch :update, format: :json, params: { instrument_id: @instrument.id, id: @code_list, rd: true, min_responses: 3, max_responses: 4, code_list: {label: @code_list.label} }
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal json['min_responses'], 3
    assert_equal json['max_responses'], 4
  end

  test "should persist order from the code parameters" do
    (code_a, code_b) = @code_list.codes
    patch :update, format: :json, params: { instrument_id: @instrument.id, id: @code_list, code_list: {label: @code_list.label, codes: [
      { id: @code_list.codes.first.id, category_id: 5263, value: "1", label: 'New Label', order: 3},
      { id: code_b.id, category_id: code_b.category_id, value: "2", label: code_b.category.label, order: 4}
    ] }}
    assert_response :success
    assert_equal [3,4], [code_a.reload.order, code_b.reload.order]
  end

  test "should destroy code_list" do
    assert_difference('CodeList.count', -1) do
      delete :destroy, format: :json, params: { instrument_id: @instrument.id, id: @code_list }
    end

    assert_response :success
  end
end

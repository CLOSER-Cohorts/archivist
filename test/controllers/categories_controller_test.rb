require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  setup do
    @user = users :User_1
    sign_in @user
    @category = categories(:Category_1)
    @instrument = instruments(:Instrument_1)
  end

  test "should get index" do
    get :index, format: :json, instrument_id: @instrument.id
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create category" do
    assert_difference('Category.count') do
      post :create, format: :json, instrument_id: @instrument.id, category: {label: @category.label, instrument_id: @instrument.id}
    end

    assert_response :success
  end

  test "should show category" do
    get :show, format: :json, instrument_id: @instrument.id, id: @category.id
    assert_response :success
  end

  test "should update category" do
    patch :update, format: :json, instrument_id: @instrument.id, id: @category, category: {label: @category.label}
    assert_response :success
  end

  test "should destroy category" do
    category = categories :Category_1572
    instrument = instruments :Instrument_3
    assert_difference('Category.count', -1) do
      delete :destroy, format: :json, instrument_id: instrument.id, id: category
    end

    assert_response :success
  end
end

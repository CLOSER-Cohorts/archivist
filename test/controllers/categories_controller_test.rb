require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  setup do
    @category = categories(:one)
    @instrument = instruments(:two)
  end

  test "should get index" do
    get :index, format: :json, instrument_id: @instrument.id
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  test "should create category" do
    assert_difference('Category.count') do
      post :create, format: :json, instrument_id: @instrument.id, category: { label: @category.label, instrument_id: @instrument.id }
    end

    assert_redirected_to category_path(assigns(:category))
  end

  test "should show category" do
    get :show, format: :json, id: @category
    assert_response :success
  end

  test "should get edit" do
    get :edit, format: :json, id: @category
    assert_response :success
  end

  test "should update category" do
    patch :update, format: :json, id: @category, category: { label: @category.label }
    assert_redirected_to category_path(assigns(:category))
  end

  test "should destroy category" do
    category = categories :three
    assert_difference('Category.count', -1) do
      delete :destroy, format: :json, id: category
    end

    assert_redirected_to categories_path
  end

  test "should not destroy category" do
    assert_difference('Category.count', 0) do
      delete :destroy, format: :json, id: @category
    end

    assert_response 400
  end
end

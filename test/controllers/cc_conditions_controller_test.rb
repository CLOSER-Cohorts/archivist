require 'test_helper'

class CcConditionsControllerTest < ActionController::TestCase
  setup do
    @user = users :User_1
    sign_in @user
    @cc_condition = cc_conditions(:CcCondition_9)
    @instrument = instruments(:Instrument_1)
    ActiveRecord::Base.connection.execute('REFRESH MATERIALIZED VIEW ancestral_topic WITH DATA')
  end

  test "should get index" do
    get :index, format: :json, params: { instrument_id: @instrument.id }
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create cc_condition" do
    assert_difference('CcCondition.count') do
      post :create, format: :json,
      params: { cc_condition: {
                  instrument_id: @instrument.id,
                  literal: @cc_condition.literal,
                  logic: @cc_condition.logic,
                  type: 'condition',
                  parent: {
                    id: @cc_condition.parent.id,
                    type: 'sequence'
                  }
                },
                instrument_id: @instrument.id }
    end

    assert_response :success
  end

  test "should show cc_condition" do
    get :show, format: :json, params: { instrument_id: @instrument.id, id: @cc_condition }
    assert_response :success
  end

  test "should update cc_condition" do
    patch :update, format: :json, params: { instrument_id: @instrument.id, id: @cc_condition, cc_condition: {literal: @cc_condition.literal, logic: @cc_condition.logic} }
    assert_response :success
  end

  test "should destroy cc_condition" do
    assert_difference('CcCondition.count', -1) do
      delete :destroy, format: :json, params: { instrument_id: @instrument.id, id: @cc_condition.id }
    end

    assert_response :success
  end
end

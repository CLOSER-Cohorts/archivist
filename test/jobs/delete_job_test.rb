require 'test_helper'

module DeleteJobTest; end

class DeleteJobTest::Instrument < ControllerTest

  setup do
    @user = users :User_1
    sign_in @user
    @instrument = instruments(:Instrument_1)
  end

  # test "should destroy instrument" do
  #   assert_difference('Instrument.count', -1) do
  #     delete :destroy, as: :json, params: { id: @instrument.id }
  #   end

  #   assert_response :success
  # end

end

    # assert_difference('CcCondition.count', -1) do
    #   delete :destroy, format: :json, params: { instrument_id: @instrument.id, id: @cc_condition.id }
    # end
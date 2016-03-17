require 'test_helper'

class InstrumentsControllerTest < ActionController::TestCase
  setup do
    @instrument = instruments(:one)
  end

  test "should get index" do
    get :index, format: :json
    assert_response :success
    assert_not_nil assigns(:instruments)
  end

  test "should create instrument" do
    assert_difference('Instrument.count') do
      post :create, format: :json, instrument: {agency: @instrument.agency, label: @instrument.label, prefix: @instrument.prefix, study: @instrument.study, version: @instrument.version}
    end

    assert_response :success
  end

  test "should show instrument" do
    get :show, format: :json, id: @instrument
    assert_response :success
  end

  test "should update instrument" do
    patch :update, format: :json, id: @instrument, instrument: {agency: @instrument.agency, label: @instrument.label, prefix: @instrument.prefix, study: @instrument.study, version: @instrument.version}
    assert_response :success
  end

  test "should destroy instrument" do
    assert_difference('Instrument.count', -1) do
      delete :destroy, format: :json, id: @instrument
    end

    assert_response :success
  end

  test "should reorder control constructs" do
    q = cc_questions(:one)
    seq = cc_sequences(:one)
    payload = [
        {
            type: 'cc_question',
            id: @instrument.cc_questions.first.id,
            parent: {
                type: 'cc_sequence',
                id: seq.id
            },
            position: 10,
            branch: 0
        }
    ]

    before = @instrument.ccs_in_ddi_order
    post :reorder_ccs, format: :json, id: @instrument, updates: payload

    assert_not_equal before, @instrument.ccs_in_ddi_order
    assert_response :success
  end

  test "should import an instrument" do
    post :import, files: []

    assert_redirected_to '/admin/import'
  end

  test "should deep copy an instrument" do
    post :copy, format: :json, id: @instrument

    assert_response :success
  end
end

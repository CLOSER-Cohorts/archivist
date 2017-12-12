require 'test_helper'

class InstrumentsControllerTest < ControllerTest
  setup do
    @user = users :User_1
    sign_in @user
    @instrument = instruments(:Instrument_1)
    #Resque.reset!
  end

  test "should get index" do
    get instruments_url, as: :json
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create instrument" do
    assert_difference('Instrument.count') do
      post instruments_url, as: :json, params: {
          instrument: {
              agency: @instrument.agency,
              label: @instrument.label,
              prefix: @instrument.prefix,
              study: @instrument.study,
              version: @instrument.version
          }
      }
      assert_response :success
    end
  end

  test "should show instrument" do
    get instrument_url(@instrument), as: :json
    assert_response :success
  end

  test "should update instrument" do
    patch instrument_url(@instrument), as: :json, params: {
        instrument: {
            agency: @instrument.agency,
            label: @instrument.label,
            prefix: @instrument.prefix,
            study: @instrument.study,
            version: @instrument.version
        }
    }
    assert_response :success
  end

  test "should destroy instrument" do
    assert_difference('Instrument.count', -1) do
      delete instrument_url(@instrument), as: :json
      assert_response :success
    end
  end

  test 'should reorder control constructs' do
    q = cc_questions(:CcQuestion_1)
    seq = cc_sequences(:CcSequence_1)
    payload = [
        {
            type: 'question',
            id: @instrument.cc_questions.first.id,
            parent: {
                type: 'sequence',
                id: seq.id
            },
            position: 10,
            branch: 0
        }
    ]

    before = @instrument.ccs_in_ddi_order
    post reorder_ccs_instrument_url(@instrument), as: :json, params: {
             updates: payload
    }

    assert_not_equal before, @instrument.ccs_in_ddi_order
    assert_response :success
  end

  test 'should import an instrument' do
    post instruments_url, params: { files: [] }

    assert_response :success
  end

  test 'should deep copy an instrument' do
    post copy_instrument_url(id: @instrument, new_prefix: 'new_one'), as: :json
  end
end

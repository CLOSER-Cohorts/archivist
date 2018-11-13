require 'test_helper'

class InstrumentsControllerTest < ActionController::TestCase
  setup do
    @user = users :User_1
    sign_in @user
    @instrument = instruments(:Instrument_1)
    #Resque.reset!
  end

  test "should get index" do
    get :index, format: :json
    assert_response :success
    assert_not_nil assigns(:collection)
  end

  test "should create instrument" do
    assert_difference('Instrument.count') do
      post :create, format: :json, params: {
          instrument: {
              agency: @instrument.agency,
              label: @instrument.label,
              prefix: @instrument.prefix + '_new',
              study: @instrument.study,
              version: @instrument.version
          }
      }
      assert_response :success
    end
  end

  test "same prefix issue" do
    assert_difference('Instrument.count', 0) do
      assert_raises(ActiveRecord::RecordInvalid) do
        post :create, as: :json, params: {
            instrument: {
                agency: @instrument.agency,
                label: @instrument.label,
                prefix: @instrument.prefix,
                study: @instrument.study,
                version: @instrument.version
            }
        }
      end
    end
  end

  test "should show instrument" do
    get :show, format: :json, params: { id: @instrument }
    assert_response :success
  end

  test "should update instrument" do
    patch :update, format: :json, params: {
        id: @instrument,
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

  # test "should destroy instrument" do
  #   puts Instrument.count
  #   assert_difference('Instrument.count', -1) do
  #     start = Time.now
  #     delete :destroy, format: :json, params: {id: @instrument.id}
  #     finish = Time.now
  #     time_diff_milli(start, finish)
  #     puts Instrument.count
  #   end
  #   assert_response :success
  # end

  # test 'should reorder control constructs' do
  #   q = cc_questions(:CcQuestion_1)
  #   seq = cc_sequences(:CcSequence_1)
  #   payload = [
  #       {
  #           type: 'question',
  #           id: @instrument.cc_questions.first.id,
  #           parent: {
  #               type: 'sequence',
  #               id: seq.id
  #           },
  #           position: 10,
  #           branch: 0
  #       }
  #   ]

  #   before = @instrument.ccs_in_ddi_order
  #   post reorder_ccs_instrument_url(@instrument), as: :json, params: {
  #            updates: payload
  #   }

  #   assert_not_equal before, @instrument.ccs_in_ddi_order
  #   assert_response :success
  # end

  # test 'should import an instrument' do
  #   Instrument.all.each {|i| puts i.prefix }
  #   puts "-" * 80
  #   assert_difference('Instrument.count') do
  #     post :import, params: { controller: :instruments, format: 'xml', files: [file_data('9999.xml')] }
  #     Instrument.all.each {|i| puts i.prefix }
  #   end

  #   assert_response :success
  # end

  # test 'should deep copy an instrument' do
  #   post copy_instrument_url(id: @instrument, new_prefix: 'new_one'), as: :json
  # end
end

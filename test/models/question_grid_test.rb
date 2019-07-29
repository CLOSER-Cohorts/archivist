require 'test_helper'

class QuestionGridTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @question_grid = question_grids :QuestionGrid_3
  end

  test "belongs to an instrument" do
    assert_kind_of Instrument, @question_grid.instrument
  end

  test "has one instruction" do
    assert_kind_of Instruction, @question_grid.instruction
  end

  test "has many response domains" do
    assert_kind_of Array, @question_grid.response_domains
  end

  test "has many response domain codes" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @question_grid.response_domain_codes
  end

  test "has many response domain datetimes" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @question_grid.response_domain_datetimes
  end

  test "has many response domain numerics" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @question_grid.response_domain_numerics
  end

  test "has many response domain texts" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @question_grid.response_domain_texts
  end

  test "has many question constructs" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @question_grid.cc_questions
    assert_equal @question_grid.constructs, @question_grid.cc_questions
  end

  test '.update cols will remove existing assocation if cols have no response domain defined' do
    assert_difference('RdsQs.count', -1) do
      cols = @question_grid.horizontal_code_list.codes.map{|code| { value: code.value, rd: nil}}
      @question_grid.update_cols(cols)
    end
  end

  test '.update cols will update existing assocation if cols has a different response domain' do
    response_domain_code = response_domain_codes :ResponseDomainCode_1
    assert_difference('RdsQs.count', 0) do
      cols = @question_grid.horizontal_code_list.codes.map{|code| { value: code.value, rd: { type: response_domain_code.class.name, id: response_domain_code.id }}}
      @question_grid.update_cols(cols)
    end
    assert_equal @question_grid.rds_qs.first.response_domain, response_domain_code
  end

  test '.update cols will create new assocation if no exisitng rds_qs was found' do
    response_domain_code = response_domain_codes :ResponseDomainCode_1
    @question_grid.rds_qs.delete_all
    assert_difference('RdsQs.count', 1) do
      cols = @question_grid.horizontal_code_list.codes.map{|code| { value: code.value, rd: { type: response_domain_code.class.name, id: response_domain_code.id }}}
      @question_grid.update_cols(cols)
    end
  end
end

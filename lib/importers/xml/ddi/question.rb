module Importers::XML::DDI
  class Question < DdiImporterBase
    RESPONSE_DOMAIN_XPATH = './CodeDomain|./NumericDomain|./TextDomain|./DateTimeDomain'
    STRUCTURED_RESPONSE_DOMAIN_XPATH = './StructuredMixedResponseDomain/ResponseDomainInMixed/CodeDomain|./StructuredMixedResponseDomain/ResponseDomainInMixed/NumericDomain|./StructuredMixedResponseDomain/ResponseDomainInMixed/TextDomain|./StructuredMixedResponseDomain/ResponseDomainInMixed/DateTimeDomain'

    def initialize(instrument)
      @instrument = instrument
    end

    def question_grid_node(node)
      question = ::QuestionGrid.new(
          {
              label: node.at_xpath('./QuestionGridName/String').content,
              literal: node.at_xpath('./QuestionText/LiteralText/Text')&.content.to_s
          }
      )
      question.horizontal_code_list = ::CodeList.find_by_identifier(
          'urn',
          extract_urn_identifier(node.at_xpath("./GridDimension[@rank='2']/CodeDomain/CodeListReference"))
      )
      question.vertical_code_list = ::CodeList.find_by_identifier(
          'urn',
          extract_urn_identifier(node.at_xpath("./GridDimension[@rank='1']/CodeDomain/CodeListReference"))
      )
      roster = node.at_xpath("./GridDimension[@rank='1']/Roster")
      unless roster.nil?
        question.roster_label = roster.at_xpath('./Label/Content').content
        question.roster_rows = roster.attribute('minimumRequired').value.nil? ? 0 : roster.attribute('minimumRequired').value.to_i
      end

      @instrument.question_grids << question

      corner = node.at_xpath("./GridDimension[@displayLabel='true']")
      question.corner_label = corner.attribute('rank').value.to_i == 1 ? 'V' : 'H' unless corner.nil?

      # Response domain work
      structured_mixed_grid_rd_node = node.at_xpath('./StructuredMixedGridResponseDomain')
      unless structured_mixed_grid_rd_node.nil?
        structured_mixed_grid_rd_node.xpath('./GridResponseDomain').each do |grd_node|
          response_domain = read_response_domain(grd_node.at_xpath(RESPONSE_DOMAIN_XPATH))
          next if response_domain.nil?

          rank_node = grd_node.xpath("./GridAttachment/CellCoordinatesAsDefined/SelectDimension[@rank='2']")
          ::RdsQs.create({
            question: question,
            response_domain: response_domain,
            code_id: rank_node.attribute('specificValue').value
          })
        end
      else
        rd_node = node.at_xpath(RESPONSE_DOMAIN_XPATH)
        unless rd_node.nil?
      response_domain = read_response_domain(rd_node)
      unless response_domain.nil?
          ::RdsQs.create(
        {
               question: question,
               response_domain: response_domain,
               rd_order: 1
        }
      )
      end
      end
    end
      question
    end

    def question_item_node(node)
      question = ::QuestionItem.new(
          {
              label: node.at_xpath('./QuestionItemName/String').content,
              literal: node.at_xpath('./QuestionText/LiteralText/Text')&.content.to_s
          }
      )
      @instrument.question_items << question

      node.xpath(RESPONSE_DOMAIN_XPATH + '|' + STRUCTURED_RESPONSE_DOMAIN_XPATH).each_with_index do |rd, i|
        response_domain = read_response_domain(rd)
        next if response_domain.nil?
        ::RdsQs.create(
            {
                         question: question,
                         response_domain: response_domain,
                         rd_order: i + 1
            }
        )
      end
      return question
    end

    def read_response_domain(node)
      if node.name == 'CodeDomain'
      cl = ::CodeList.find_by_identifier(
        'urn',
        extract_urn_identifier(node.at_xpath('./CodeListReference'))
      )
      response_cardinality = node.at_xpath('./ResponseCardinality')
      if response_cardinality
        min_responses = response_cardinality['minimumResponses']
        max_responses = response_cardinality['maximumResponses']
        cl.create_response_domain_code(min_responses: min_responses, max_responses: max_responses)
      end
      response_domain = cl.response_domain
    else
      if node.name == 'NumericDomain'
      response_domain = read_rdn_node node
      elsif node.name == 'TextDomain'
      response_domain = read_rdt_node node
      elsif node.name == 'DateTimeDomain'
      response_domain = read_rdd_node node
      else
      Rails.logger.warn 'ResponseDomain not supported'
      return nil
      end
    end
    return response_domain
    end

    def read_rdd_node(node)
      label = node.at_xpath('Label/Content')&.content
      response_domain = @instrument.response_domain_datetimes.find_by_label label
      if response_domain.nil?
        response_domain = @instrument.response_domain_datetimes.create(
             {
                 label: label,
                 datetime_type: node.at_xpath('DateTypeCode').content,
                 format: node.at_xpath('DateFieldFormat')&.content
             }
        )
      end
      return response_domain
    end

    def read_rdn_node(node)
      label = node.at_xpath('./Label/Content')&.content
      response_domain = @instrument.response_domain_numerics.find_by_label label
      if response_domain.nil?
        response_domain = @instrument.response_domain_numerics.create(
            {
                label: label,
                numeric_type: node.at_xpath('NumericTypeCode').content,
                min: node.at_xpath('NumberRange/Low')&.content,
                max: node.at_xpath('NumberRange/High')&.content
            }
        )
      end
      return response_domain
    end

    def read_rdt_node(node)
      label = node.at_xpath('Label/Content')&.content
      if label.nil?
        if node['maxLength'].nil?
          label = 'MISSING LABEL'
        else
          label = 'max:' + node['maxLength']
        end
      end
      response_domain = @instrument.response_domain_texts.find_by_label label
      if response_domain.nil?
        response_domain = @instrument.response_domain_texts.create ({
            label: label,
            maxlen: node['maxLength']
        })
      end
      return response_domain
    end

    def XML_node(node)
      if node.name == 'QuestionItem'
        question = question_item_node node
      elsif node.name == 'QuestionGrid'
        question = question_grid_node node
      else
        Rails.logger.debug 'Question not recogonised: ' + node.name
        return
      end

      unless node.at_xpath('./InterviewerInstructionReference').nil?
        question.instruction_id = ::Instruction.find_by_identifier(
            'urn',
            extract_urn_identifier(node.at_xpath('./InterviewerInstructionReference'))
        ).try(:id)
      end
      question.save!
      question.add_urn extract_urn_identifier node
    end

    def XML_scheme(scheme)
      scheme.xpath('./QuestionItem | ./QuestionGrid').each do |question_node|
        XML_node question_node
      end
    end
  end
end

module Importers::XML::DDI
  class Question < DdiImporterBase
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
        question.roster_label = roster.at_xpath('./Label/r:Content').content
        question.roster_rows = roster.attribute('minimumRequired').value.nil? ? 0 : roster.attribute('minimumRequired').value.to_i
      end

      @instrument.question_grids << question

      corner = node.at_xpath("./GridDimension[@displayLabel='true']")
      question.corner_label = corner.attribute('rank').value.to_i == 1 ? 'V' : 'H' unless corner.nil?

      # Response domain work
    end

    def question_item_node(node)
      question = ::QuestionItem.new(
          {
              label: node.at_xpath('./QuestionItemName/String').content,
              literal: node.at_xpath('./QuestionText/LiteralText/Text')&.content.to_s
          }
      )
      @instrument.question_items << question

      node.xpath('./CodeDomain|'\
          './NumericDomain|'\
          './TextDomain|'\
          './DateTimeDomain'\
          ).each_with_index do |rd, i|

        if rd.name == 'CodeDomain'
          cl = ::CodeList.find_by_identifier(
              'urn',
              extract_urn_identifier(rd.at_xpath('./CodeListReference'))
          )
          cl.response_domain = true
          response_domain = cl.response_domain
        else
          if rd.name == 'NumericDomain'
            response_domain = read_rdn_node rd
          elsif rd.name == 'TextDomain'
            response_domain = read_rdt_node rd
          elsif rd.name == 'DatetimeDomain'
            response_domain = read_rdd_node rd
          else
            Rails.logger.warn 'ResponseDomain not supported'
            next
          end
        end
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

      end
      unless node.at_xpath('./InterviewerInstructionReference').nil?
        question.instruction = ::Instruction.find_by_identifier(
            'url',
            extract_urn_identifier(node.at_xpath('./InterviewerInstructionReference'))
        )
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

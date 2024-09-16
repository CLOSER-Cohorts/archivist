class Instruments::MappingsTsvDataService
  def initialize(object, unmapped_variables)
    @object = object
    @unmapped_variables = unmapped_variables
    @tsv_data = []
  end

  def generate_tsv_data
    generate_question_items
    generate_unmapped_variables
    @tsv_data
  end

  private

  def generate_question_items
    @object.cc_questions.each do |qc|
      if qc.question.question_type == 'QuestionItem'
        process_question_item(qc)
      else
        process_other_question_types(qc)
      end
    end
  end

  def process_question_item(qc)
    if qc.variables.empty?
      @tsv_data << {
        label: "#{qc.label}$0;0",
        question_text: qc.question.literal,
        question_topic_id: qc.topic.try(:code),
        questionnaire_prefix: @object.prefix,
        variable_name: nil,
        variable_topic_id: nil,
        variable_label: nil,
        dataset_prefix: nil
      }
    else
      qc.variables.each do |variable|
        @tsv_data << {
          label: "#{qc.label}$0;0",
          question_text: qc.question.literal,
          question_topic_id: qc.topic.try(:code),
          questionnaire_prefix: @object.prefix,
          variable_name: variable.name,
          variable_topic_id: variable.topic.try(:code),
          variable_label: variable.label,
          dataset_prefix: variable.dataset.instance_name
        }
      end
    end
  end

  def process_other_question_types(qc)
    if qc.maps.where(x: nil, y: nil).empty?
      @tsv_data << {
        label: "#{qc.label}$0;0",
        question_text: qc.question.literal,
        question_topic_id: qc.topic.try(:code),
        questionnaire_prefix: @object.prefix,
        variable_name: nil,
        variable_topic_id: nil,
        variable_label: nil,
        dataset_prefix: nil
      }
    else
      qc.maps.where(x: nil, y: nil).each do |map|
        @tsv_data << {
          label: "#{qc.label}$0;0",
          question_text: qc.question.literal,
          question_topic_id: qc.topic.try(:code),
          questionnaire_prefix: @object.prefix,
          variable_name: map.variable.name,
          variable_topic_id: map.variable.topic.try(:code),
          variable_label: map.variable.label,
          dataset_prefix: map.variable.dataset.instance_name
        }
      end
    end

    process_question_codes(qc)
  end

  def process_question_codes(qc)
    qc.question.horizontal_code_list.codes.each_with_index do |_, x|
      qc.question.vertical_code_list.codes.map { |c| c.category.label }.each_with_index do |category, y|
        if qc.maps.where(x: x + 1, y: y + 1).empty?
          @tsv_data << {
            label: "#{qc.label}$#{x + 1};#{y + 1}",
            question_text: "#{qc.question.literal} #{category}",
            question_topic_id: qc.topic.try(:code),
            questionnaire_prefix: @object.prefix,
            variable_name: nil,
            variable_topic_id: nil,
            variable_label: nil,
            dataset_prefix: nil
          }
        else
          qc.maps.where(x: x + 1, y: y + 1).each do |map|
            @tsv_data << {
              label: "#{qc.label}$#{x + 1};#{y + 1}",
              question_text: "#{qc.question.literal} #{category}",
              question_topic_id: qc.topic.try(:code),
              questionnaire_prefix: @object.prefix,
              variable_name: map.variable.name,
              variable_topic_id: map.variable.topic.try(:code),
              variable_label: map.variable.label,
              dataset_prefix: map.variable.dataset.instance_name
            }
          end
        end
      end
    end
  end

  def generate_unmapped_variables
    @unmapped_variables.each do |variable|
      @tsv_data << {
        label: nil,
        question_text: nil,
        question_topic_id: nil,
        questionnaire_prefix: nil,
        variable_name: variable.name,
        variable_topic_id: variable.topic.try(:code),
        variable_label: variable.label,
        dataset_prefix: variable.dataset.instance_name
      }
    end
  end
end
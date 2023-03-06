class Variables::Serializer

  attr_accessor :dataset

  def initialize(dataset=nil)
    self.dataset = dataset
  end

  def call
    all
  end

  private

  def all
    connection = ActiveRecord::Base.connection
    sql = %|
            SELECT variables.id, variables.name, variables.label, variables.var_type, variables.dataset_id, links.topic_id as topic,
              array_remove(ARRAY_AGG (question_maps.source_id), NULL) questions,
              array_remove(ARRAY_AGG (src_variables.id), NULL) src_variables,
              array_remove(ARRAY_AGG (used_by.id), NULL) used_bys,
              CASE WHEN variables.var_type = 'Derived' THEN der_src_links.topic_id ELSE src_links.topic_id END as sources_topic
            FROM variables
            LEFT OUTER JOIN links ON links.target_id = variables.id AND links.target_type = 'Variable' AND links.target_id = variables.id
            LEFT OUTER JOIN maps AS question_maps ON question_maps.variable_id = variables.id AND question_maps.source_type = 'CcQuestion'
            LEFT OUTER JOIN maps AS src_variable_maps ON src_variable_maps.variable_id = variables.id AND src_variable_maps.source_type = 'Variable'
            LEFT OUTER JOIN maps AS used_by_maps ON used_by_maps.source_id = variables.id
            LEFT OUTER JOIN variables AS src_variables ON src_variable_maps.source_id = src_variables.id
            LEFT OUTER JOIN variables AS used_by ON used_by_maps.variable_id = used_by.id
            LEFT OUTER JOIN links AS src_links ON src_links.target_id = question_maps.source_id AND src_links.target_type = 'CcQuestion'
            LEFT OUTER JOIN links AS der_src_links ON der_src_links.target_id = src_variable_maps.source_id AND src_links.target_type = 'Variable'
            WHERE variables.dataset_id = #{dataset.id}
            GROUP BY variables.id, links.topic_id, src_links.topic_id, der_src_links.topic_id
            ORDER BY variables.id DESC
          |

    variables = connection.select_all(sql).to_a

    variables = pg_array_converstion(variables)

    variables = format_output_hash(variables)
    return variables
  end

  def get_variables
    dataset.variables.inject({}){ |h, v|  h[v.id] = { id: v.id, name: v.name, var_type: v.var_type, class: 'Variable' }; h }
  end

  def get_topics(ids=[])
    Topic.where(id: ids).inject({}){ |h, v|  h[v.id] = { id: v.id, code: v.code, name: v.name, parent_id: v.parent_id }; h }
  end

  def get_questions(ids=[])
    CcQuestion.where(id: ids).inject({}){ |h, v|  h[v.id] = { id: v.id, label: v.label, class: 'CcQuestion' }; h }
  end

  def pg_array_converstion(variables)
    variables.map do | variable |
      ["questions", "src_variables", "used_bys"].each do | att |
        variable[att] = variable[att].gsub(/}|{/,'').split(',').map(&:to_i)
      end
      variable
    end
  end

  def format_output_hash(variables)
    vars = get_variables
    questions = get_questions(variables.map{|v|v["questions"]}.flatten.uniq)
    topics = get_topics(variables.map{|v|v["sources_topic"]}.flatten.uniq + variables.map{|v|v["topic"]}.flatten.uniq)

    variables = variables.group_by{|v| v['id']}.map do | i, grouped_variables |
      variable = grouped_variables.first.dup

      variable = merge_src_variables(variable, grouped_variables)

      variable["src_variables"] = variable["src_variables"].map{|src_var| vars[src_var]}
      variable["questions"] = variable["questions"].map{|src_var| questions[src_var]}

      if variable["var_type"] == "Derived"
        variable["sources"] = variable["src_variables"].uniq
        # If derived then we should take the sources_topic from the source variables.
        unless variable["sources"].empty?
          source_variable = variables.find{|c| c["id"] == variable["sources"].first[:id]}
          variable["sources_topic"] = source_variable.fetch("topic") || source_variable.fetch("sources_topic")
        end
      else
        variable["sources"] = variable["questions"].uniq
      end
      variable.delete("src_variables")
      variable.delete("questions")
      variable["used_bys"] = variable["used_bys"].map{|src_var| vars[src_var]}
      variable["sources_topic"] = topics[variable["sources_topic"]] if variable["sources_topic"]
      variable["topic"] = topics[variable["topic"]] if variable["topic"]
      variable["resolved_topic"] = variable["topic"] || variable["sources_topic"]
      variable
    end

    return variables
  end

  def merge_src_variables(variable, grouped_variables)
    variable["src_variables"] = grouped_variables.map{|var| var["src_variables"]}.flatten.sort
    first_source = variable["src_variables"].first
    if first_source
      variable["sources_topic"] = grouped_variables.find{|var| var["src_variables"].include?(first_source)}.fetch("sources_topic", nil)
    end
    return variable
  end
end
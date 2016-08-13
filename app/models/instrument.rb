class Instrument < ActiveRecord::Base

  has_many :cc_conditions, -> { includes :cc }, dependent: :destroy
  has_many :cc_loops, -> { includes :cc }, dependent: :destroy
  has_many :cc_sequences, -> { includes :cc }, dependent: :destroy
  has_many :cc_statements, -> { includes :cc }, dependent: :destroy

  has_many :code_lists, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :codes, dependent: :destroy

  has_many :question_grids, -> { includes [
                                              :response_domain_datetimes,
                                              :response_domain_numerics,
                                              :response_domain_texts,
                                              response_domain_codes: [
                                                  code_list: [
                                                      codes: [
                                                          :category
                                                      ]
                                                  ]
                                              ],
                                              vertical_code_list: [
                                                  codes: [
                                                      :category
                                                  ]
                                              ],
                                              horizontal_code_list: [
                                                  codes: [
                                                      :category
                                                  ]
                                              ]
                                          ] }, dependent: :destroy
  has_many :question_items, -> { includes [
                                              :response_domain_datetimes,
                                              :response_domain_numerics,
                                              :response_domain_texts,
                                              response_domain_codes: [
                                                  code_list: [
                                                      codes: [
                                                          :category
                                                      ]
                                                  ]
                                              ]
                                          ] }, dependent: :destroy

  has_many :cc_questions, -> { includes :cc }, dependent: :destroy
  has_many :control_constructs, dependent: :destroy

  has_many :instructions, dependent: :destroy

  has_many :response_domain_codes, dependent: :destroy
  has_many :response_domain_datetimes, dependent: :destroy
  has_many :response_domain_numerics, dependent: :destroy
  has_many :response_domain_texts, dependent: :destroy
  has_many :rds_qs, class_name: 'RdsQs', dependent: :destroy

  has_many :response_units, dependent: :destroy

  has_many :instruments_datasets, class_name: 'InstrumentsDatasets'
  has_many :datasets, through: :instruments_datasets

  include Realtime::RtUpdate

  after_create :add_top_sequence
  around_destroy :pause_rt

  def conditions
    self.cc_conditions
  end

  def loops
    self.cc_loops
  end

  def questions
    self.cc_questions
  end

  def sequences
    self.cc_sequences
  end

  def statements
    self.cc_statements
  end

  def response_domains
    self.response_domain_datetimes.to_a + self.response_domain_numerics.to_a +
        self.response_domain_texts.to_a + self.response_domain_codes.to_a
  end

  def ccs
    self.cc_conditions.to_a + self.cc_loops.to_a + self.cc_questions.to_a +
        self.cc_sequences.to_a + self.cc_statements.to_a
  end

  def top_sequence
    self
        .cc_sequences
        .joins('INNER JOIN control_constructs as cc ON cc_sequences.id = cc.construct_id AND cc.construct_type = \'CcSequence\'')
        .where('cc.parent_id IS NULL')
        .first
  end

  def ccs_in_ddi_order
    output = []
    harvest = lambda do |parent|
      output.append parent
      if parent.class.method_defined? :children
        parent.children.each { |child| harvest.call child.construct }
      end
    end
    harvest.call self.top_sequence
    output
  end

  def add_top_sequence
    self.cc_sequences.create
  end

  def pause_rt
    Realtime.do_silently do
      yield
    end
  end

  def export_time
    begin
      $redis.hget 'export:instruments:' + self.id.to_s, 'time'
    rescue
      nil
    end
  end

  def export_url
    begin
      $redis.hget 'export:instruments:' + self.id.to_s, 'url'
    rescue
      nil
    end
  end

  def last_edited_time
    begin
      $redis.hget 'last_edit:instrument', self.id
    rescue
      nil
    end
  end

  def copy(new_prefix, other_vals = {})

    new_i = self.dup
    new_i.prefix = new_prefix
    other_vals.select do |key, val|
      new_i[key] = val
    end
    new_i.save!
    new_i.cc_sequences.first.destroy

    ref = {}
    ref[:control_constructs] = {}
    ccs = {}
    [
        :categories,
        :code_lists,
        :codes,
        :response_domain_codes,
        :response_domain_datetimes,
        :response_domain_numerics,
        :response_domain_texts,
        :response_units,
        :instructions,
        :question_items,
        :question_grids,
        :cc_conditions,
        :cc_loops,
        :cc_questions,
        :cc_sequences,
        :cc_statements,
        :rds_qs
    ].each do |key|
      ref[key] = {}
      self.__send__(key).find_each do |obj|
        new_obj = obj.dup
        ref[key][obj.id] = new_obj

        obj.class.reflections.select do |association_name, reflection|
          if association_name.to_s != 'instrument' && reflection.macro == :belongs_to
            unless obj.__send__(association_name).nil?
              new_obj.association(association_name).writer(ref[obj.__send__(association_name).class.name.tableize.to_sym][obj.__send__(association_name).id])
            end
          end
        end
        new_i.__send__(key) << new_obj
        if new_obj.is_a? Construct::Model
          ccs[new_obj.cc.id] = obj.cc
          ref[:control_constructs][obj.cc.id] = new_obj.cc
        end
      end
    end

    ### Rebuild the control construct tree
    new_i.control_constructs.find_each do |cc|
      cc.position = ccs[cc.id].position
      cc.branch = ccs[cc.id].branch
      cc.label = ccs[cc.id].label

      cc.parent = ref[:control_constructs][ccs[cc.id].parent_id]
      cc.save!
    end

    new_i
  end

  def cc_count
    stats = self.association_stats
    stats['cc_conditions'] + stats['cc_loops'] + stats['cc_questions'] +
        stats['cc_sequences'] + stats['cc_statements']
  end

  def last_export_time
    begin
      File.mtime 'tmp/exports/' + prefix + '.xml'
    rescue
      false
    end
  end

  def self.generate_last_edit_times
    last_edit_times = {}
    Instrument.reflections.keys.each do |r|
      next if ['instruments_datasets', 'datasets'].include? r
      sql = 'SELECT instrument_id, MAX(updated_at) FROM ' + r + ' GROUP BY instrument_id'
      results = ActiveRecord::Base.connection.execute(sql)
      results.each do |r|
        last_edit_times[r['instrument_id']] = [last_edit_times[r['instrument_id']], r['max']].reject { |x| x.nil? }.max
      end
    end
    sql = 'SELECT id, updated_at FROM instruments'
    results = ActiveRecord::Base.connection.execute(sql)
    results.each do |r|
      last_edit_times[r['id']] = [last_edit_times[r['id']], r['updated_at']].reject { |x| x.nil? }.max
    end
    last_edit_times.select do |k, v|
      $redis.hset 'last_edit:instrument', k, v
    end
  end
end

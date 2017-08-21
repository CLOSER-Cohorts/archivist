# The Instrument is based on the Instrument model from DDI3.X and is one of the
# champion models that pulls together Archivist.
#
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/datacollection_xsd/elements/Instrument.html
#
# === Properties
# * Agency
# * Version
# * Prefix
# * Label
# * Study
class Instrument < ApplicationRecord
  # This model is exportable as DDI
  include Exportable

  # This model can be tracked using an Identifier
  include Identifiable

  # This model is an update point for archivist-realtime
  include Realtime::RtUpdate

  # Used to create CLOSER UserID and URNs
  #
  # @type [String]
  URN_TYPE = 'in'

  # XML tag name
  #
  # @type [String]
  TYPE = 'Instrument'

  # List of direct properties that an instrument has
  #
  # This is effectively the list of associations, but with some of
  # the junction tables removed.
  #
  # @type [Array]
  PROPERTIES = [
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
  ]

  # An instrument can have many CcConditions
  has_many :cc_conditions,
           -> { includes( :topic ) }, dependent: :destroy
  # An instrument can have many CcLoops
  has_many :cc_loops,
           -> { includes( :topic ) }, dependent: :destroy
  # An instrument can have many CcSequences
  has_many :cc_sequences,
           -> { includes( :topic ) }, dependent: :destroy
  # An instrument can have many CcStatement
  has_many :cc_statements, dependent: :destroy
  # An instrument can have many CodeLists
  has_many :code_lists, dependent: :destroy

  # An instrument can have many Categories
  has_many :categories, dependent: :destroy

  # An instrument keeps track of many Codes as junctions
  has_many :codes, dependent: :destroy

  # An instrument can have many QuestionGrids
  has_many :question_grids, -> { includes [
                                              :instruction,
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

  # An instrument can have many QuestionItems
  has_many :question_items, -> { includes [
                                              :instruction,
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

  # An instrument can have many CcQuestions
  has_many :cc_questions,
           -> { includes(:question, :response_unit, :variables, :topic) },
           dependent: :destroy

  # An instrument can have many Instructions
  has_many :instructions, dependent: :destroy

  # An instrument can have many ResponseDomainCodes
  has_many :response_domain_codes, dependent: :destroy

  # An instrument can have many ResponseDomainDatetimes
  has_many :response_domain_datetimes, dependent: :destroy

  # An instrument can have many ResponseDomainNumerics
  has_many :response_domain_numerics, dependent: :destroy

  # An instrument can have many ResponseDomainTexts
  has_many :response_domain_texts, dependent: :destroy

  # An instrument keeps track of many RdsQs as junctions
  has_many :rds_qs, class_name: 'RdsQs', dependent: :destroy

  # An instrument can have many ResponseUnits
  has_many :response_units, dependent: :destroy

  # Junction relationship to Datasets
  has_many :instruments_datasets, class_name: 'InstrumentsDatasets'

  # Many-to-many relationship with Datasets
  #
  # This is used as a scoping mechanism to speed up CcQuestion to
  # Variable mapping
  has_many :datasets, through: :instruments_datasets

  # List of all documents attached to this instrument
  has_many :documents, -> { order :created_at }, as: :item

  # Allows an instrument to access a database view that reformats
  # an instruments Q-V mapping file
  has_many :qv_mappings

  # After creating a new instrument a first sequence is created as
  # a top sequence
  after_create :add_top_sequence

  # After creating a new instrument add the instrument Prefix to
  # cache
  after_create :register_prefix

  # After updating an instrument, refresh the Prefix cache
  after_update :reregister_prefix

  # While destroying an instrument, pause archivist-realtime updates
  around_destroy :pause_rt

  # After destroying an instrument, remove its Prefix from cache
  after_destroy :deregister_prefix

  # Update cache with freshly generated last editted times for  all
  # instruments
  #
  # This last editted time includes all objects that belongs to an
  # Instrument. For example, if a Category label is editted, then
  # the last editted time will be the category's updated_at time.
  def self.generate_last_edit_times
    last_edit_times = {}

    find_max_edit_time = lambda do |res, id|
      res.each do |r|
        last_edit_times[r[id]] = [
            last_edit_times[r[id]],
            r['max']
        ].reject { |x| x.nil? }.max
      end
    end

    Instrument.reflections.keys.each do |res|
      next if %w(instruments_datasets datasets).include? res
      sql = 'SELECT instrument_id, MAX(updated_at) FROM ' + res + ' GROUP BY instrument_id'
      results = ActiveRecord::Base.connection.execute sql
      find_max_edit_time.call results, 'instrument_id'
    end
    sql = 'SELECT id, updated_at FROM instruments'
    results = ActiveRecord::Base.connection.execute sql
    find_max_edit_time.call results, 'id'

    begin
      last_edit_times.select do |k, v|
        $redis.hset 'last_edit:instrument', k, v
      end
    rescue => e
      Rails.logger.warn 'Could not set last edit times'
      Rails.logger.warn e.message
    end
  end

  # Alias for accessing CcConditions relation
  #
  # @return [ActiveRecord::Associations::CollectionProxy]
  def conditions
    self.cc_conditions
  end

  def ccs
    self.cc_conditions.to_a + self.cc_loops.to_a + self.cc_questions.to_a +
        self.cc_sequences.to_a + self.cc_statements.to_a
  end

  # Gets the number of constructs
  #
  # @return [Integer] Number of constructs
  def cc_count
    stats = self.association_stats
    stats['cc_conditions'] + stats['cc_loops'] + stats['cc_questions'] +
        stats['cc_sequences'] + stats['cc_statements']
  end

  # Get all of the constructs in order from the top sequence down
  # @return [Array] Flat array of constructs
  def ccs_in_ddi_order
    output = []
    harvest = lambda do |parent|
      output.append parent
      if parent.class.method_defined? :children
        parent.children.each &harvest
      end
    end
    harvest.call self.top_sequence
    output
  end

  # Clears the control construct tree cache
  def clear_cache
    ccs.each &:clear_cache
  end

  # Deep copies an instrument
  #
  # In order to deep copy an instrument, all models that belong to the original
  # instrument are also copied. Then seperately the control construct tree is
  # recompiled.
  #
  # @param [String] new_prefix Prefix of instrument to be created
  # @param [Hash] other_vals Optional additional values to set instead of being copied
  #
  # @return [Instrument] Returns the newly copied instrument
  def copy(new_prefix, other_vals = {})

    new_i = self.dup
    new_i.prefix = new_prefix
    other_vals.select { |key, val| new_i[key] = val }

    new_i.save!
    new_i.cc_sequences.first.destroy

    ref = {control_constructs: {}}
    ccs = {}
    PROPERTIES.each do |key|
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

  # Destroys an entire instrument with all contents
  #
  # TODO: Correctly configure relations and dependants to allow Rails default to work correctly
  def destroy
    InstrumentsDatasets.where(instrument_id: self.id).delete_all
    PROPERTIES.reverse.map(&:to_s).each do |r|
      next if ['datasets'].include? r
      begin
        klass = r.classify.constantize
      rescue
        klass = r.classify.pluralize.constantize
      end
      klass.where(instrument_id: self.id).destroy_all
    end
    sql = 'DELETE FROM instruments WHERE id = ' + self.id.to_s
    ActiveRecord::Base.connection.execute(sql)
  end

  # Gets the time of the last export from the Redis cache
  #
  # @returns [String] Last export time
  def export_time
    begin
      $redis.hget 'export:instrument:' + self.id.to_s, 'time'
    rescue
      nil
    end
  end

  # The the URL of the last export from the Redis cache
  #
  # @returns [String] Last export URL
  def export_url
    begin
      $redis.hget 'export:instrument:' + self.id.to_s, 'url'
    rescue
      nil
    end
  end

  # Gets the time of the last edit to an instrument item from the cache
  #
  # @returns [String] Time of last edit
  def last_edited_time
    begin
      $redis.hget 'last_edit:instrument', self.id
    rescue
      nil
    end
  end

  # Gets the modified time of the last file export to tmp
  #
  # @deprecated Do we still export to file and this is not thread safe
  # @returns [String] Last export time from file
  def last_export_time
    begin
      File.mtime 'tmp/exports/' + prefix + '.xml'
    rescue
      false
    end
  end

  # Simple alias for cc_loops
  #
  # @returns [ActiveRecord::Associations::CollectionProxy] List of all {CcLoop loops}
  def loops
    self.cc_loops
  end

  # Accepts a block for which realtime updates should not be run
  def pause_rt
    Realtime.do_silently do
      yield
    end
  end

  # Simple alias for cc_questions
  #
  # @returns [ActiveRecord::Associations::CollectionProxy] List of all {CcQuestion question} constructs
  def questions
    self.cc_questions
  end

  # Returns the number of Q-V maps
  #
  # @returns [Number] Number of Q-V maps
  def qv_count
    self.qv_mappings.count
  end

  # Returns an array of all response domains
  #
  # @returns [Array] All response domains
  def response_domains
    self.response_domain_datetimes.to_a + self.response_domain_numerics.to_a +
        self.response_domain_texts.to_a + self.response_domain_codes.to_a
  end

  # Simple alias for cc_sequences
  #
  # @returns [ActiveRecord::Associations::CollectionProxy] List of all {CcSequence sequences}
  def sequences
    self.cc_sequences
  end

  # Simple alias for cc_statements
  #
  # @returns [ActiveRecord::Associations::CollectionProxy] List of all {CcStatement statements}
  def statements
    self.cc_statements
  end

  # Returns the top sequence for the instrument
  #
  # @deprecated Should be replaced with a db-view based function
  # @returns [CcSequence] Top sequence
  def top_sequence
    self
        .cc_sequences
        .joins('INNER JOIN control_constructs as cc ON cc_sequences.id = cc.construct_id AND cc.construct_type = \'CcSequence\'')
        .where('cc.parent_id IS NULL')
        .first
  end

  # Returns a list of all variables scoped for mapping
  #
  # @returns [ActiveRecord::Relation] All possible variables for mapping
  def variables
    Variable.where(dataset_id: self.datasets.map(&:id))
  end

  private
  # Creates an empty sequence as the top-sequence, i.e. parentless
  def add_top_sequence
    self.cc_sequences.create(label: 'TopSequence')
  end

  # Removes prefix from Redis cache
  def deregister_prefix
    ::Prefix.destroy self.prefix
  end

  # Adds prefix to Redis cache as alias of id
  def register_prefix
    ::Prefix[self.prefix] = self.id
  end

  # Removed the prefix and then re-add it to Redis cache
  def reregister_prefix
    deregister_prefix
    register_prefix
  end
end

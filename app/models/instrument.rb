# frozen_string_literal: true

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

  # Use FriendlyId to create slugs
  extend FriendlyId

  # Used to create CLOSER UserID and URNs
  URN_TYPE = 'in'

  # XML tag name
  TYPE = 'Instrument'

  # List of direct properties that an instrument has
  #
  # This is effectively the list of associations, but with some of
  # the junction tables removed.
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
           -> { includes( :parent ) }, dependent: :destroy
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
                                              :instruction
                                          ] }, dependent: :destroy

  # An instrument can have many CcQuestions
  has_many :cc_questions,
           -> { includes(:variables, :topic) },
           dependent: :destroy

  has_many :maps, through: :cc_questions

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
  has_many :rds_qs, -> { includes(:question_item) }, class_name: 'RdsQs', dependent: :destroy

  # An instrument can have many ResponseUnits
  has_many :response_units, dependent: :destroy

  # Junction relationship to Datasets
  has_many :instruments_datasets, class_name: 'InstrumentsDatasets', dependent: :destroy

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

  # An Instrument can have many {Import Imports}
  has_many :imports

  # After creating a new instrument a first sequence is created as
  # a top sequence
  after_create :add_top_sequence

  validates :prefix, uniqueness: true

  friendly_id :prefix, use: :slugged

  # Update cache with freshly generated last editted times for  all
  # instruments
  #
  # This last editted time includes all objects that belongs to an
  # Instrument. For example, if a Category label is editted, then
  # the last editted time will be the category's updated_at time.
  def self.generate_last_edit_times
    last_edit_times = {}

    find_max_edit_time = lambda do |res, id|
      res.each { |r| last_edit_times[r[id]] = [last_edit_times[r[id]],r['max']].reject { |x| x.nil? }.max }
    end

    Instrument.reflections.keys.each do |res|
      next if %w(instruments_datasets datasets identifiers documents qv_mappings dv_mappings).include? res
      sql = 'SELECT instrument_id, MAX(updated_at) FROM ' + res + ' GROUP BY instrument_id'
      results = ActiveRecord::Base.connection.execute sql
      find_max_edit_time.call results, 'instrument_id'
    end
    results = ActiveRecord::Base.connection.execute 'SELECT id, updated_at FROM instruments'
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

  def add_export_document(doc)
    self.documents << doc
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
  #
  # @return [Array] Flat array of constructs
  def ccs_in_ddi_order
    output = []
    harvest = lambda do |parent|
      output.append parent
      if parent.class.method_defined? :children
        parent.children.each(&harvest)
      end
    end
    harvest.call self.top_sequence
    output
  end

  # Clears the control construct tree cache
  def clear_cache
    ccs.each(&:clear_cache)
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
      next if [:cc_conditions, :cc_loops, :cc_questions, :cc_sequences, :cc_statements].include?(key)
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
      end
    end

    ### Copy the control construct tree
    new_top_sequence = self.top_sequence.dup
    new_top_sequence.instrument_id = new_i.id
    new_top_sequence.save!
    deep_copy_children = lambda do |new_item, item|
      item.children.each do |child|
        new_child = child.dup
        new_child.instrument_id = new_i.id

        child.class.reflections.select do |association_name, reflection|
          if association_name.to_s != 'instrument' && association_name.to_s != 'parent' && reflection.macro == :belongs_to
            unless child.__send__(association_name).nil?
              new_child.association(association_name).writer(ref[child.__send__(association_name).class.name.tableize.to_sym][child.__send__(association_name).id])
            end
          end
        end

        new_item.children << new_child
        new_item.save!
        if child.is_a?(ParentalConstruct)
          deep_copy_children.call(new_child, child)
        end
      end
    end

    deep_copy_children.call(new_top_sequence, self.top_sequence)

    new_i
  end

  # Gets the time of the last export from the Redis cache
  #
  # @return [String] Last export time
  def export_time
    begin
      latest_export.try(:created_at)
    rescue
      nil
    end
  end

  # The the URL of the last export from the Redis cache
  #
  # @return [String] Last export URL
  def export_url
    begin
      "/instruments/#{self.id}/export/#{latest_export.try(:id)}"
    rescue
      nil
    end
  end

  # The latest instrument_export document created
  #
  # @return [Document] Last export document
  def latest_export
    begin
      documents.where(document_type: 'instrument_export').last
    rescue
      nil
    end
  end

  # Gets the time of the last edit to an instrument item from the cache
  #
  # @return [String] Time of last edit
  def last_edited_time
    begin
      $redis.hget 'last_edit:instrument', self.id
    rescue
      nil
    end
  end

  # Simple alias for cc_questions
  #
  # @return [ActiveRecord::Associations::CollectionProxy] List of all {CcQuestion question} constructs
  def questions
    self.cc_questions
  end

  # Returns the number of Q-V maps
  #
  # @return [Number] Number of Q-V maps
  def qv_count
    self.qv_mappings.size
  end

  # Returns an array of all response domains
  #
  # @return [Array] All response domains
  def response_domains
    self.response_domain_datetimes.to_a + self.response_domain_numerics.to_a +
        self.response_domain_texts.to_a + self.response_domain_codes.to_a
  end

  # Returns the top sequence for the instrument
  #
  # @deprecated Should be replaced with a db-view based function
  # @return [CcSequence] Top sequence
  def top_sequence
    self
        .cc_sequences
        .joins('INNER JOIN control_constructs as cc ON cc_sequences.id = cc.construct_id AND cc.construct_type = \'CcSequence\'')
        .where('cc.parent_id IS NULL')
        .first
  end

  # Returns a list of all variables scoped for mapping
  #
  # @return [ActiveRecord::Relation] All possible variables for mapping
  def variables
    Variable.where(dataset_id: self.datasets.map(&:id))
  end

  def normalize_friendly_id(value)
    value.to_s.parameterize(preserve_case: true)
  end

  def control_construct_scheme
    prefix + '_ccs01'
  end

  private
  # Creates an empty sequence as the top-sequence, i.e. parentless
  def add_top_sequence
    self.cc_sequences.create(label: nil)
  end

  # Regenerates friendly id slug when prefix changes
  def should_generate_new_friendly_id?
    self.changes.has_key?(:prefix)
  end
end

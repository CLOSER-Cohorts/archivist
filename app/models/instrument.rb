class Instrument < ActiveRecord::Base

  has_many :cc_conditions, -> { includes :cc }, dependent: :destroy
  has_many :cc_loops, -> { includes :cc }, dependent: :destroy
  has_many :cc_questions, -> { includes :cc }, dependent: :destroy
  has_many :cc_sequences, -> { includes :cc }, dependent: :destroy
  has_many :cc_statements, -> { includes :cc }, dependent: :destroy

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

  has_many :code_lists, dependent: :destroy
  has_many :categories, dependent: :destroy

  has_many :instructions, dependent: :destroy

  has_many :response_domain_datetimes, dependent: :destroy
  has_many :response_domain_numerics, dependent: :destroy
  has_many :response_domain_texts, dependent: :destroy
  has_many :response_units, dependent: :destroy

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
end

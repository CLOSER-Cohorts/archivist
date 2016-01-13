class Instrument < ActiveRecord::Base
  has_many :categories
  has_many :cc_conditions, -> { includes :cc }
  has_many :cc_loops, -> { includes :cc }
  has_many :cc_questions, -> { includes :cc }
  has_many :cc_sequences, -> { includes :cc }
  has_many :cc_statements, -> { includes :cc }
  has_many :code_lists
  has_many :instructions
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
  ] }
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
  ] }
  has_many :response_domain_datetimes
  has_many :response_domain_numerics
  has_many :response_domain_texts
  has_many :response_units
end

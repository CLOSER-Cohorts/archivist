class Instrument < ActiveRecord::Base
  has_many :categories
  has_many :cc_conditions
  has_many :cc_loops
  has_many :cc_questions
  has_many :cc_sequences
  has_many :cc_statements
  has_many :code_lists
  has_many :instructions
  has_many :question_grids
  has_many :question_items
  has_many :response_domain_datetimes
  has_many :response_domain_numerics
  has_many :response_domain_texts
  has_many :response_units
end

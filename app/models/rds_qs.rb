# A junction model to join response domains and questions
#
# Allows many-to-many connections between an instruments
# {Question::Model questions} and its
# {ResponseDomain response domains}. The junction also holds the order of the
# response domains when a question has multiple response domains. If
# the question is a {QuestionGrid}, then _code_id_ is used to denote
# the column of the response domain.
#
# === Properties
# * code_id
# * rd_order
class RdsQs < ApplicationRecord
  # All joins must belong to an {Instrument} for security
  belongs_to :instrument

  # All joins need a single {Question::Model question}
  belongs_to :question, polymorphic: true

  # All joins need a single {ResponseDomain response domain}
  belongs_to :response_domain, polymorphic: true

  # Before creating a join in the database ensure the instrument has been set
  before_create :set_instrument

  # Sets instrument_id from either the {Question::Model question} or {ResponseDomain response domain}
  def set_instrument
    if self.instrument_id.nil?
      self.instrument_id = question.instrument_id || response_domain.instrument_id
    end
  end
end

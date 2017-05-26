class QvMapping < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :dataset
  belongs_to :instrument

  def question_with_cell
    self.question + ((self.x.nil? || self.y.nil?) ? '' : "$#{self.x};#{self.y}")
  end
end
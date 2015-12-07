class Instruction < ActiveRecord::Base
  belongs_to :instrument
  has_many :question_items, dependent: :nullify
  has_many :question_grids, dependent: :nullify

  def questions
    self.question_items.to_a + self.question_grids.to_a
  end
end

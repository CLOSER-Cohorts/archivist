class Group < ApplicationRecord
  has_many :users
  serialize :study

  before_save :remove_study_labelling

  private
  def remove_study_labelling
    if study.is_a? Array
      study.map! do |s|
        if s.is_a? Hash
          s[:label]
        else
          s
        end
      end
      study.reject! &:blank?
    end
  end
end

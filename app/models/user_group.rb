# frozen_string_literal: true

# UserGroup represents a set of {User Users} that are interested in particular
# studies
#
# === Properties
# * group_type
# * label
# * study
class UserGroup < ApplicationRecord
  # Each UserGroup can have multiple {User Users}
  has_many :users, inverse_of: :group, foreign_key: :group_id

  # Study can hold either a String or an Array, but is still stored in a single
  # database column
  serialize :study

  # Before saving clear study value
  before_save :remove_study_labelling

  private # Private methods

  # In case more than just the study label is submitted extract the label from
  # saving
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

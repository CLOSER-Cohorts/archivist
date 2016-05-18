class Group < ActiveRecord::Base
  has_many :users
  serialize :study


end

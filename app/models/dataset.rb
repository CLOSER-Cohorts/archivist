class Dataset < ActiveRecord::Base
  has_many :variables, dependent: :destroy
end

class User < ActiveRecord::Base
  # Others available are:
  # :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  belongs_to :group

  delegate :study, to: :group

  enum role: [ :reader, :editor, :admin]
end

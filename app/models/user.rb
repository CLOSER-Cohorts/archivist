class User < ApplicationRecord
  belongs_to :user_group

  delegate :study, to: :user_group

  # Others available are:
  # :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  enum role: [:reader, :editor, :admin]

  def self.setup_initial_superuser(params)
    begin
      if params['su-password'] == params['su-confirm'] && params['su-password'].length > 7
        g = Group.create label: params['su-group'], group_type: 'Centre', study: '*'
        u = User.new email: params['su-email'],
                     first_name: params['su-fname'],
                     last_name: params['su-lname']
        u.password = params['su-password']
        u.group = g
        u.save!
        u.admin!
        u.confirm
      end
    rescue
      Rails.logger.error 'Could not create the initial superuser.'
    end
  end

  # new function to set the password without knowing the current
  # password used in our confirmation controller.
  def attempt_set_password(params)
    p = {}
    p[:password] = params[:password]
    p[:password_confirmation] = params[:password_confirmation]
    update_attributes(p)
  end

  # new function to return whether a password has been set
  def has_no_password?
    self.encrypted_password.blank?
  end

  # Devise::Models:unless_confirmed` method doesn't exist in Devise 2.0.0 anymore.
  # Instead you should use `pending_any_confirmation`.
  def only_if_unconfirmed
    pending_any_confirmation { yield }
  end

  def password_match?
    self.errors[:password] << "can't be blank" if password.blank?
    self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
    self.errors[:password_confirmation] << 'does not match password' if password != password_confirmation
    password == password_confirmation && !password.blank?
  end

  def password_required?
    # Password is required if it is being set, but not for new records
    if !persisted?
      false
    else
      !password.nil? || !password_confirmation.nil?
    end
  end

  def status
    return 'unconfirmed' unless self.confirmed?
    return 'locked' if self.access_locked?
    'active'
  end
end

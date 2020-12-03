# The User class representers a user account, controlling
# authentication and authorization
class User < ApplicationRecord
  # All Users must belong to a {UserGroup}
  belongs_to :group, class_name: 'UserGroup'

  # Users do not have their own label, so it is delegated to the {UserGroup} it belongs to
  delegate :study, to: :user_group

  # Others available are:
  # :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  # Enum holding the possible roles for any User
  enum role: [:reader, :editor, :admin]

  # Used to create the first {User} when the app is first
  # initialized
  #
  # @param [Hash] params First User parameters
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

  # Sets the password without knowing the current
  # password used in our confirmation controller.
  #
  # @param [Hash] params New password and confirmation
  def attempt_set_password(params)
    p = {}
    p[:password] = params[:password]
    p[:password_confirmation] = params[:password_confirmation]
    update_attributes(p)
  end

  # Returns whether a password has been set
  #
  # @return [Boolean] True if no password has been set
  def has_no_password?
    self.encrypted_password.blank?
  end

  # Method wrapper for performing if the User has not
  # be confirmed
  #
  # @yield Method to be executed only if User is not confirmed
  def only_if_unconfirmed
    pending_any_confirmation { yield }
  end

  # Checks whether the password is suitable and matches
  # the confirmation
  #
  # @return [Boolean] True if the password is good for use
  def password_match?
    self.errors[:password] << "can't be blank" if password.blank?
    self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
    self.errors[:password_confirmation] << 'does not match password' if password != password_confirmation
    password == password_confirmation && !password.blank?
  end

  # Checks whether a password is required
  #
  # @return [Boolean] True if a password is required
  def password_required?
    # Password is required if it is being set, but not for new records
    if !persisted?
      false
    else
      !password.nil? || !password_confirmation.nil?
    end
  end

  # Returns pretty label of the current User status
  #
  # @return [String] Pretty status label
  def status
    return 'unconfirmed' unless self.confirmed?
    return 'locked' if self.access_locked?
    'active'
  end

  def after_database_authentication
    update_column(:api_key, SecureRandom.hex(10))
  end
end

class MyCustomAuth < DerailedBenchmarks::AuthHelper
  attr_writer :user

  # Include devise test helpers and turn on test mode
  # We need to do this on the class level
  def setup
    # self.class.instance_eval do
    require 'devise'
    require 'warden'
    extend ::Warden::Test::Helpers
    extend ::Devise::TestHelpers
    Warden.test_mode!
    # end
  end

  def user
    if @user
      @user = @user.call if @user.is_a?(Proc)
      @user
    else
      @group = Group.create label: 'Dummy', group_type: 'Centre', study: '*'
      password = SecureRandom.hex
      @user = User.first_or_create!(
          email: "#{SecureRandom.hex}@example.com",
          password: password,
          password_confirmation: password,
          group_id: @group.id
      )
      @user.confirm
      @user.admin!
      @user
    end
  end

  # Logs the user in, then call the parent app
  def call(env)
    login_as(user)
    app.call(env)
  end
end


DerailedBenchmarks.auth = MyCustomAuth.new
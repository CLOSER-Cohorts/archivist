# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# <<< Creating User Groups >>>
#
g1 = UserGroup.create(id: 1, group_type: "Centre", label: "CLOSER", study: "*")

# <<< End of Creating User Groups >>>

# <<< Creating Users >>>
#
# If you need more users, simply copy and paste the code below and edit new users details accordingly.
# confirmation_tokens must be unique
# Roles: 'admin', 'reader', or 'editor'

# Admin user
admin1 = User.create( id: 1, email: "admin1@email.com", first_name: "Admin", last_name: "One", group_id: 1, role: "admin", password: "Password123", password_confirmation: "Password123", confirmation_token: 'XM2oSPVexoYNkHhzYJqk', confirmed_at: Time.now )

# Reader user
reader1 = User.create( id: 2, email: "reader1@email.com", first_name: "Reader", last_name: "One", group_id: 1, role: "reader", password: "Password123", password_confirmation: "Password123", confirmation_token: 'xPT8fwPsA6Nr_vJgz3SD', confirmed_at: Time.now )
#
# Editor
editor1 = User.create( id: 3, email: "editor1@email.com", first_name: "Editor", last_name: "One", group_id: 1, role: "editor", password: "Password123", password_confirmation: "Password123", confirmation_token: 'G9E3uVfnyn2C3zzGZHzY', confirmed_at: Time.now )
# <<< End of Creating Users >>>


# <<< Creating Topics >>>
#
t0 = Topic.create( id: 0, name: 'None', code: '000' )

# <<< end of Creating Topics >>>

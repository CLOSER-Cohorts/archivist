# frozen_string_literal: true

json.array!(@collection) do |user|
  json.extract! user, :id, :email, :first_name, :last_name, :group_id, :role, :group_label
  json.status user.status
end
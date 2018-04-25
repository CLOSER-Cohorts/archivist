json.array!(@collection) do |user|
  json.extract! user, :id, :email, :first_name, :last_name, :group_id, :role
  json.status user.status
end
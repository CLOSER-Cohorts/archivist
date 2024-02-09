# frozen_string_literal: true

json.extract! @object, :id, :email, :first_name, :last_name, :group_id, :role, :study
json.status @object.status
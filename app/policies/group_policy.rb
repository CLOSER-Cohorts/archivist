class GroupPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.group.study == '*'
        scope.all
      else
        scope.where(id: user.group)
      end
    end
  end
end
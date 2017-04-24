class DatasetPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none if user.nil?
      if user.group.study == '*'
        scope.all
      else
        scope.where(study: user.group.study)
      end
    end
  end
end
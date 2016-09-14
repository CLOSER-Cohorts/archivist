class InstrumentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.group.study == '*'
        scope.all
      else
        scope.where(study: user.group.study)
      end
    end
  end
end
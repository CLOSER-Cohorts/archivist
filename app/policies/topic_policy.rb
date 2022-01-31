# frozen_string_literal: true

class TopicPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
# frozen_string_literal: true

class DatasetPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      u = user #|| User.where(api_key: params[:api_key]).where('api_key IS NOT NULL').first
      begin
        if u.group.study == '*'
          return scope.all
        else
          return scope.where(study: u.group.study)
        end
      rescue
        return scope.none
      end
    end
  end
end
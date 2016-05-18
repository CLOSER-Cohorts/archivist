class CcStatement < ActiveRecord::Base
  include Construct::Model

  URN_TYPE = 'si'
  TYPE = 'StatementItem'

  def self.create_with_position(params)
    obj = new()
    i = Instrument.find(params[:instrument_id])
    i.send('cc_' + params[:type].pluralize) << obj

    parent = i.send('cc_' + params[:parent][:type].pluralize).find(params[:parent][:id])
    unless parent.nil?
      obj.position = parent.last_child.position + 1

      unless params[:branch].nil?
        obj.branch = params[:branch]
      end
    end
    obj.label = params[:label]
    obj.label = params[:literal]
    parent.children << obj.cc
    obj.save!
    obj
  end
end

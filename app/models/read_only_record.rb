class ReadOnlyRecord < ActiveRecord::Base
  self.abstract_class = true

  attr_readonly *column_names

  def readonly?
    true
  end

  def destroy
    raise ActiveRecord::ReadOnlyRecord
  end

  def delete
    raise ActiveRecord::ReadOnlyRecord
  end
end
# An abstract class to represent a read only connection to the database
#
# Typically this abstract model should be used with a read only database view.
class ReadOnlyRecord < ActiveRecord::Base
  self.abstract_class = true

  #attr_readonly *column_names

  # Returns whether the record is read only
  #
  # @return [true] Always true
  def readonly?
    true
  end

  # Destroys the record
  #
  # Overloads the default functionality of ActiveRecord and raises an exception instead.
  #
  # @raise [ActiveRecord::ReadOnlyRecord] Prevents alterations to the record
  def destroy
    raise ActiveRecord::ReadOnlyRecord
  end

  # Deletes the record
  #
  # Overloads the default functionality of ActiveRecord and raises an exception instead.
  #
  # @raise [ActiveRecord::ReadOnlyRecord] Prevents alterations to the record
  def delete
    raise ActiveRecord::ReadOnlyRecord
  end
end
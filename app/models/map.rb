# A junction model to create mappings
#
# Performs either Q-V mapping for DV mapping by joining
# a {Variable} to either a {CcQuestion} or another
# Variable.
#
# === Properties
# * x
# * y
class Map < ApplicationRecord
  # Each mapping needs a source {CcQuestion} or {Variable}
  belongs_to :source, polymorphic: true
  # Every mapping has a destination {Variable}
  belongs_to :variable

  # Validate to stop topic conflict between Variable(s) and CcQuestion
  validate :resolved_topic_conflict

  def resolved_topic_conflict
    return if source.resolved_topic.nil? || variable.resolved_topic.nil?
    errors.add(:topic, I18n.t('activerecord.errors.models.map.attributes.resolved_topic.variables_conflict', variable: variable, source: source, variable_topic: variable.resolved_topic, source_topic: source.resolved_topic))
  end
end

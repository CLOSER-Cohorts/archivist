# frozen_string_literal: true

module ApplicationHelper
  # A helper method to display text which is html_safe and has newlines removed
  def d(string)
    return unless string
    string.gsub(/[\r\n]/, ' ').html_safe
  end
end
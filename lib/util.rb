module Util
  def self.question_label(name)
    name.sub(/^q[cig]_/,'').sub(/_/, ' ').gsub(/_/, ')')
  end
end
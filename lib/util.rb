module Util
  def self.question_label(name)
    chunks = name.sub(/^q[cig]_/,'').sub(/_/, ' ').split(/_/)
    if chunks.length > 1
      return chunks[0] + '(' + chunks[1] + ')'
    else
      return chunks[0]
    end
  end
end
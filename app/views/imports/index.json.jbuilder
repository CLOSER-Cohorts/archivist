# frozen_string_literal: true

json.array!(@imports) do |import|
  json.partial! 'item', import: import
end

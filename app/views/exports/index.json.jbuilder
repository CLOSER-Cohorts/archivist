# frozen_string_literal: true

json.array!(@exports) do |export|
  json.partial! 'item', export: export
end

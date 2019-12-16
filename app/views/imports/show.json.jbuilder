json.partial! 'item', import: @import
json.logs(@import.parsed_log) do | log_entry |
  json.original_text log_entry[:input]
  json.matches log_entry[:matches]
  json.outcome log_entry[:outcome]
  json.error log_entry[:error]
end

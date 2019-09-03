json.partial! 'item', import: @import
json.logs(@import.log.split('\n')) do | log_line |
  json.original_text log_line.split(' - ')[0]
  json.matches log_line.split(' - ')[1]
  json.outcome log_line.split(' - ')[2]
  json.error log_line.split(' - ')[2] =~ /Invalid/
end

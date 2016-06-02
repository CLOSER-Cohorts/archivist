json.extract! @object, :id, :label, :group_type
if @object.study.is_a? Array
  json.study @object.study do |study|
    json.label study
  end
else
  json.study @object.study
end
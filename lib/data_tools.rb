module DataTools
  class << self
    def similar_strands(datasets)
      vars = []
      datasets.each do |d|
        obj = {}
        d.variables.each do |v|
          obj[v.name] = v.label
        end
        vars << obj
      end

      first = vars.shift

      output = []
      first.each_key do |k|
        output << { 0 => k }
        vars.each_with_index do |set, i|
          found = set.select { |name, label| label == first[k] }
          output.last[i + 1] = found.keys.first if found&.count == 1
        end
      end

      return output
    end
  end
end
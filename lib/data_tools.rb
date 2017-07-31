module DataTools
  class << self
    def similar_strands(datasets)
      datasets = datasets.to_a

      first = datasets.shift

      output = []
      first.variables.find_each do |v|
        output << { 0 => v.name }
        datasets.each_with_index do |dataset, i|
          fz = FuzzyMatch.new(dataset.variables, read: :label, gather_last_result: :true)
          fz.find(v.label)
          output.last[i + 1] = fz.last_result.winner.name if fz.last_result&.score&.to_f > 0.5
        end
      end

      return output.select{ |o| o.size > 1 }
    end
  end
end
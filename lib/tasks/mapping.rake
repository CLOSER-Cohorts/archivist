namespace :mapping do

  desc 'Clear and build all strands'
  task compile_strands: :environment do
    Strand.delete_all

    CcQuestion.find_each do |qc|
      s = Strand.new [qc]
      s.save
    end
    Variable.find_each do |var|
      s = Strand.new [var]
      s.save
    end

    Map.where(source_type: CcQuestion).find_each do |map|
      s1 = Strand.find_by_member map.source
      s2 = Strand.find_by_member map.variable

      s3 = s1 + s2
      s3.save
    end
  end
end
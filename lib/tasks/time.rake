desc 'Time question_items caching'
task :question_items => :environment do

  Instrument.all.each do

  end

  beginning_time = Time.now

  Instrument.all.each do |i|
    qis = i.question_items
  end

  end_time = Time.now
  puts "Time elapsed #{(end_time - beginning_time)*1000} milliseconds for standard\n"

  beginning_time = Time.now

  Instrument.all.each do |i|
    qis = i.db_question_items
  end

  end_time = Time.now
  puts "Time elapsed #{(end_time - beginning_time)*1000} milliseconds for db_\n"

  beginning_time = Time.now

  Instrument.all.each do |i|
    qis = i.ro_question_items
  end

  end_time = Time.now
  puts "Time elapsed #{(end_time - beginning_time)*1000} milliseconds for ro_\n"

  beginning_time = Time.now

  Instrument.all.each do |i|
    qis = JSON.parse($redis.get('instruments/' + i.id.to_s + '/question_items'))
  end

  end_time = Time.now
  puts "Time elapsed #{(end_time - beginning_time)*1000} milliseconds for hacked"

end
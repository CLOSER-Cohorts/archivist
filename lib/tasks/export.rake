namespace :export do

  desc 'Export all updated instruments'
  task instruments: :environment do
    Instrument.find_each do |i|
      next if i.last_edited_time.nil?
      if i.export_time.nil? || Date.parse(i.export_time.to_s) < Date.parse(i.last_edited_time.to_s)
        Resque.enqueue ExportJob::Instrument, i.id
      end
    end
  end
end

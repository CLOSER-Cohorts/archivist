namespace :export do

  desc 'Export all updated instruments'
  task instruments: :environment do
    Instrument.find_each do |i|
      if i.export_time.nil? || i.export_time < i.last_edited_time
        Resque.enqueue ExportJob::Instrument, i.id
      end
    end
  end
end
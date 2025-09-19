namespace :documents do
  desc "Clean up old documents"
  task cleanup: :environment do
    puts "Starting document cleanup..."
    
    # Show summary first
    summary = Document.import_export_summary
    puts "Current state:"
    puts "  Total documents: #{summary[:documents][:total]}"
    puts "  Safe to delete: #{summary[:documents][:safe_to_delete]}"
    
    # Perform cleanup
    deleted_count = Document.cleanup_old_documents(dry_run: false)
    puts "Cleanup completed: #{deleted_count} documents deleted"
  end
  
  desc "Preview document cleanup (dry run)"
  task preview: :environment do
    puts "Document cleanup preview (dry run)..."
    
    summary = Document.import_export_summary
    puts "Current state:"
    puts "  Total documents: #{summary[:documents][:total]}"
    puts "  Safe to delete: #{summary[:documents][:safe_to_delete]}"
    
    count = Document.cleanup_old_documents(dry_run: true)
    puts "Would delete #{count} documents"
  end
  
  desc "Queue all documents for individual cleanup via Sidekiq"
  task queue_all: :environment do
    puts "Queuing all documents for individual cleanup..."
    
    total_documents = Document.count
    puts "Total documents: #{total_documents}"
    
    queued_count = 0
    Document.find_each(batch_size: 1000) do |document|
      DeleteJob::Document.perform_async(document.id)
      queued_count += 1
      
      if queued_count % 1000 == 0
        puts "Queued #{queued_count}/#{total_documents} documents..."
      end
    end
    
    puts "Completed: queued #{queued_count} documents for cleanup"
    puts "Check Sidekiq web interface to monitor progress"
  end
  
  desc "Queue only safe-to-delete documents for cleanup via Sidekiq"
  task queue_safe: :environment do
    puts "Queuing safe-to-delete documents for cleanup..."
    
    safe_documents = Document.safe_to_delete
    total_safe = safe_documents.count
    puts "Safe to delete: #{total_safe} documents"
    
    queued_count = 0
    safe_documents.find_each(batch_size: 1000) do |document|
      DeleteJob::Document.perform_async(document.id)
      queued_count += 1
      
      if queued_count % 1000 == 0
        puts "Queued #{queued_count}/#{total_safe} documents..."
      end
    end
    
    puts "Completed: queued #{queued_count} safe-to-delete documents for cleanup"
    puts "Check Sidekiq web interface to monitor progress"
  end
end
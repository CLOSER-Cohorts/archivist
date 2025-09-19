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
end
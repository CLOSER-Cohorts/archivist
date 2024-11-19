module Importers::XML::DDI
  class Dataset < DdiImporterBase
    def initialize(thing, options = {})
      if thing.is_a? String
        @doc = open(thing) { |f| Nokogiri::XML(f) }
        @filepath = thing
      else
        @document = Document.find thing
        @doc = Nokogiri::XML @document.file_contents
        @filepath = @document.filename
      end
      @doc.remove_namespaces!
      @counters = {}
    end

    def cancel
      @dataset.destroy
    end

    def import(options = {})
      options.symbolize_keys!

      if options.has_key? :import_id
        @import = Import.find_by_id(options[:import_id])
      end

      set_import_to_running
      begin
        ActiveRecord::Base.transaction do
          @dataset = self.class.build_dataset( @doc, filename: File.basename(@filepath))
          unless @document.nil?
            @document.item = @dataset
            @document.save!
          end
          read_variables
        end
      rescue => e
        @errors = true
        log :input, e.input if e.respond_to?(:input)
        log :matches, e.record.inspect if e.respond_to?(:record)
        log :outcome, "Record Invalid : #{e.message}"
        write_to_log
      ensure
        set_import_to_finished
      end    
    end

    def read_variables
      vars = @doc.xpath '//Variable'
      vars.each do |var|
        v = Variable.new
        v.name = var.at_xpath('./VariableName/String').content
        v.label = var.at_xpath('./Label/Content').content
        v.var_type = 'Normal'
        @dataset.variables << v
      end
    end

    def self.build_dataset(doc, options = {})
      d = ::Dataset.new
      d.name = doc.at_xpath('//PhysicalInstance/Citation/Title/String').content
      d.doi = doc.at_xpath('//DataFileURI').content
      d.filename = options[:filename] unless options[:filename].nil?
      d.save!
      d
    end

    def object
      @dataset
    end
  end
end

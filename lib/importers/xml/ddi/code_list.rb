module Importers::XML::DDI
  class CodeList < DdiImporterBase
    def initialize(instrument)
      @instrument = instrument
    end

    def XML_node(node)
      codes_to_add = []
      node.xpath('./Code').each_with_index do |code, i|
        begin
          co = Code.new ({
              value: code.at_xpath('./Value').content,
              order: i + 1
          })
          co.category = Category.find_by_identifier(
              'urn',
              extract_urn_identifier(code.at_xpath('./CategoryReference'))
          )
          codes_to_add << co
        rescue
          Rails.logger.warn 'Code failed to be imported.'
        end
      end

      begin
        cl = ::CodeList.new label: node.at_xpath('./Label/Content').content
      rescue
        cl = ::CodeList.new label: codes_to_add.map {|c| c.category.label.gsub(/\s*(\S)\S*/, '\1')}.join('_')
      end
      cl.instrument_id = @instrument.id
      cl.save!
      codes_to_add.each {|c| cl.codes << c}
      cl.add_urn extract_urn_identifier node
    end

    def XML_scheme(scheme)
      scheme.xpath('./CodeList').each do |code_list_node|
        XML_node code_list_node
      end
    end
  end
end
module Exporters::XML::DDI
  # DDI 3.2 XML Exporter for {::Dataset}
  #
  # {::Dataset} is a direct alias of DDI 3.2 Dataset.
  #
  # This is not a real exporter, it actually performs transformations
  # on the file imported and held in the database as a Document.
  #
  # @see ::Dataset
  class Dataset
    # Exports the {::Dataset} in DDI 3.2
    #
    # Performs transformations to the existing XML document to add
    # CLOSER IDs.
    #
    # @param [::Dataset] dataset Either the Dataset exporting
    # @return [Nokogiri::XML::Document] Updated XML document
    def run(dataset)
      documents = Document.where(item: dataset).order(created_at: :asc)
      unless documents.empty?
        document = documents.first
        @doc = Nokogiri::XML document.file_contents

        vsn = @doc.at_xpath('//ddi:VariableSchemeName/r:String')&.content.to_s.underscore

        vars = @doc.xpath '//ddi:Variable'
        vars.each do |var|
          vn = var.at_xpath('ddi:VariableName/r:String')&.content.to_s.underscore
          urn = var.at_xpath './r:URN'
          urn.after create_uid([vsn,'va',vn])

          vclref = var.at_xpath('ddi:VariableRepresentation/r:CodeRepresentation/r:CodeListReference/r:URN')&.content.to_s
          vcl_node = @doc.at_xpath("//ddi:CodeList/r:URN[text()='#{vclref}']")&.parent
          unless vcl_node.nil?
            vcl_urn = vcl_node.at_xpath 'r:URN'
            vcl_urn.after create_uid([vsn,'vcl',vn])

            cat_counter = 1
            vcl_node.xpath('ddi:Code/r:CategoryReference/r:URN').each do |vca_ref|
              vca_node = @doc.at_xpath("//ddi:Category/r:URN[text()='#{vca_ref&.content}']")&.parent
              unless vca_node.nil?
                vca_urn = vca_node.at_xpath './r:URN'
                vca_urn.after create_uid([vsn,'vca',vn,'%06d' % cat_counter])

                cat_counter += 1
              end
            end
          end

          vs_counter = 1
          vs_nodes = @doc.xpath(
              "//pi:StatisticalSummary/pi:VariableStatistics/r:VariableReference/r:URN[text()='#{urn&.content}']"
          ).map { |x| x&.parent&.parent }.compact
          vs_nodes.each do |vs_node|
            vs_urn = vs_node.at_xpath './r:URN'
            vs_urn.after create_uid([vsn,'vs',vn,'%06d' % vs_counter])

            vs_counter += 1
          end
        end
        @doc
      end
    end

    def doc
      @doc
    end

    private
    def create_uid(id_bits)
      node = Nokogiri::XML::Node.new 'r:UserID', @doc
      node['typeOfUserID'] = 'closer:id'
      node.content = id_bits.join '-'
      node
    end
  end
end
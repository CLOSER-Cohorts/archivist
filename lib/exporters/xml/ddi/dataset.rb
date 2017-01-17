module Exporters::XML::DDI
  class Dataset
    def run(dataset)
      documents = Document.where(item: dataset).order(created_at: :asc)
      unless documents.empty?
        document = documents.first
        @doc = Nokogiri::XML document.file_contents

        vsn = @doc.at_xpath('//ddi:VariableSchemeName/r:String')&.content.to_s.underscore

        vars = @doc.xpath '//ddi:Variable'
        vars.each do |var|
          vn = var.at_xpath('ddi:VariableName/r:String')&.content.to_s.underscore
          uid = Nokogiri::XML::Node.new 'r:UserID', @doc
          uid['typeOfUserID'] = 'closer:id'
          uid.content = [vsn,'va',vn].join '-'
          urn = var.at_xpath './r:URN'
          urn.after uid

          vclref = var.at_xpath('ddi:VariableRepresentation/r:CodeRepresentation/r:CodeListReference/r:URN')&.content.to_s
          vcl_node = @doc.at_xpath("//ddi:CodeList/r:URN[text()='#{vclref}']")&.parent
          unless vcl_node.nil?
            vcl_uid = Nokogiri::XML::Node.new 'r:UserID', @doc
            vcl_uid['typeOfUserID'] = 'closer:id'
            vcl_uid.content = [vsn,'vcl',vn].join '-'
            vcl_urn = vcl_node.at_xpath 'r:URN'
            vcl_urn.after vcl_uid

            cat_counter = 1
            vcl_node.xpath('ddi:Code/r:CategoryReference/r:URN').each do |vca_ref|
              vca_node = @doc.at_xpath("//ddi:Category/r:URN[text()='#{vca_ref&.content}']")&.parent
              unless vca_node.nil?
                vca_uid = Nokogiri::XML::Node.new 'r:UserID', @doc
                vca_uid['typeOfUserID'] = 'closer:id'
                vca_uid.content = [vsn,'vca',vn,'%06d' % cat_counter].join '-'
                vca_urn = vca_node.at_xpath './r:URN'
                vca_urn.after vca_uid

                cat_counter += 1
              end
            end
          end

          vs_counter = 1
          vs_nodes = @doc.xpath(
              "//pi:StatisticalSummary/pi:VariableStatistics/r:VariableReference/r:URN[text()='#{urn&.content}']"
          ).map { |x| x&.parent&.parent }.compact
          vs_nodes.each do |vs_node|
            vs_uid = Nokogiri::XML::Node.new 'r:UserID', @doc
            vs_uid['typeOfUserID'] = 'closer:id'
            vs_uid.content = [vsn,'vs',vn,'%06d' % vs_counter].join '-'
            vs_urn = vs_node.at_xpath './r:URN'
            vs_urn.after vs_uid

            vs_counter += 1
          end
        end
        @doc
      end
    end
    def doc
      @doc
    end
  end
end
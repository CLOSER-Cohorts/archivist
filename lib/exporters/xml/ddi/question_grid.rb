module Exporters::XML::DDI
  # DDI 3.2 XML Exporter for {::QuestionGrid}
  #
  # {::QuestionGrid} is a direct alias of DDI 3.2 QuestionItem.
  #
  # === Example
  #   doc = Nokogiri::XML::Document.new
  #   qg = QuestionGrid.first
  #   exporter = Exporters::XML::DDI::QuestionGrid.new doc
  #   xml_node = exporter.V3_2(qg)
  #
  # @see ::QuestionGrid
  class QuestionGrid < Exporters::XML::DDI::Question
    # Exports the {::QuestionGrid} in DDI 3.2
    #
    # Create a single XML node as an export of a single {::QuestionGrid}.
    # In order to be valid DDI, this node then needs to be wrapped
    # either in a QuestionScheme or a Fragment.
    #
    # @param [::QuestionGrid|Integer] qgrid_id Either the QuestionGrid or QuestionGrid ID for exporting
    # @return [Nokogiri::XML::Node] New XML node
    def V3_2(qgrid_id)
      @klass = ::QuestionGrid

      super do |qgrid, qg|

        add_grid_dimension = lambda do |rank, axis, cl|
          gd = Nokogiri::XML::Node.new 'd:GridDimension', @doc
          gd['rank'] = rank
          gd['displayCode'] = 'false'
          gd['displayLabel'] = if qgrid.corner_label == axis then 'true' else 'false' end

          cd = Nokogiri::XML::Node.new 'd:CodeDomain', @doc
          cd.add_child create_reference_string 'r:CodeListReference', cl
          gd.add_child cd

          return gd
        end

        unless qgrid.vertical_code_list.nil?
          gdy = add_grid_dimension.call('1', 'V', qgrid.vertical_code_list)
          qg.add_child gdy
        end

        unless qgrid.roster_rows == 0
          gdr = Nokogiri::XML::Node.new 'd:GridDimension', @doc
          gdr['rank'] = 1
          gdr['displayCode'] = 'false'
          gdr['displayLabel'] = 'false'
          gdr.add_child <<~XML.delete("\n")
            <d:Roster baseCodeValue="1" codeIterationValue="1" minimumRequired="#{qgrid.roster_rows}">
            <r:Label>
            <r:Content xml:lang="en-GB">#{CGI::escapeHTML(qgrid.roster_label.to_s)}</r:Content>
            </r:Label>
            </d:Roster>
          XML
          qg.add_child gdr
        end

        unless qgrid.horizontal_code_list.nil?
          gdx = add_grid_dimension.call('2', 'H', qgrid.horizontal_code_list)
          qg.add_child gdx
        end

        rd_wrapper = qg
        if qgrid.response_domains.count > 1
          rd_wrapper = Nokogiri::XML::Node.new 'd:StructuredMixedGridResponseDomain', @doc
          qg.add_child rd_wrapper
        end

        qgrid.response_domains.each_with_index do |rd, i|
          case rd
            when ResponseDomainCode
              cd = Nokogiri::XML::Node.new 'd:CodeDomain', @doc
              cd.add_child create_reference_string 'r:CodeListReference', rd.code_list

              rd_wrapper.add_child wrap_grid_response_domain cd, qgrid.response_domains.count, i + 1

            when ResponseDomainText
              td = build_response_domain_text(rd)
              rd_wrapper.add_child wrap_grid_response_domain td, qgrid.response_domains.count, i + 1

            when ResponseDomainDatetime
              dd = build_response_domain_datetime(rd)
              rd_wrapper.add_child wrap_grid_response_domain dd, qgrid.response_domains.count, i + 1

            when ResponseDomainNumeric
              nd = build_response_domain_numeric rd
              rd_wrapper.add_child wrap_grid_response_domain nd, qgrid.response_domains.count, i + 1
          end
        end

        unless qgrid.instruction.nil?
          iif = create_reference_string 'd:InterviewerInstructionReference', qgrid.instruction
          qg.add_child iif
        end
      end
    end

    private  # Private methods
    # Attaches a response domain to a specific grid column
    #
    # If the {::QuestionGrid} has more than one different type of response
    # domain then they need to be attached to specific columns.
    #
    # TODO: Does this function need rd_count?
    #
    # @param [Nokogiri::XML::Node] node Response domain for wrapping
    # @param [Integer] rd_count Number of response domains the grid has
    # @param [Integer] col Column to attach the response domain to
    # @return [Nokogiri::XML::Node] Wrapped response domain node
    def wrap_grid_response_domain(node, rd_count, col)
      if rd_count > 1
        wrapper = Nokogiri::XML::Node.new 'd:GridResponseDomain', @doc
        wrapper.add_child node
        wrapper.add_child <<~XML.delete("\n")
            <d:GridAttachment>
            <d:CellCoordinatesAsDefined>
            <d:SelectDimension rank="1" allValues="true" />
            <d:SelectDimension rank="2" specificValue="#{col}" />
            </d:CellCoordinatesAsDefined>
            </d:GridAttachment>
        XML
        return wrapper
      else
        return node
      end
    end
  end
end
module Exporters::XML::DDI
  class QuestionGrid < Question
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
            <r:Content xml:lang="en-GB">#{qgrid.roster_label}</r:Content>
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
              td = Nokogiri::XML::Node.new 'd:TextDomain', @doc
              unless rd.maxlen.nil?
                td['maxLength'] = rd.maxlen
              end
              td.add_child "<r:Label><r:Content xml:lang=\"en-GB\">%{label}</r:Content></r:Label>" %
                               {label: rd.label}

              rd_wrapper.add_child wrap_grid_response_domain td, qgrid.response_domains.count, i + 1

            when ResponseDomainDatetime
              dd = Nokogiri::XML::Node.new 'd:DateTimeDomain', @doc
              dd.add_child "<r:DateFieldFormat>%{format}</r:DateFieldFormat><r:DateTypeCode>%{type}</r:DateTypeCode><r:Label><r:Content xml:lang=\"en-GB\">%{label}</r:Content></r:Label>" %
                               {label: rd.label, type: rd.datetime_type, format: rd.format || ''}

              rd_wrapper.add_child wrap_grid_response_domain dd, qgrid.response_domains.count, i + 1

            when ResponseDomainNumeric
              nd = Nokogiri::XML::Node.new 'd:NumericDomain', @doc
              nd.add_child "<r:NumberRange>%{range}</r:NumberRange><r:NumericTypeCode>%{type}</r:NumericTypeCode><r:Label><r:Content xml:lang=\"en-GB\">%{label}</r:Content></r:Label>" %
                               {
                                   label: rd.label,
                                   type: rd.numeric_type,
                                   range: (if rd.min then "<r:Low>%d</r:Low>" % rd.min else '' end) + (if rd.max then "<r:High>%d</r:High>" % rd.max else '' end)
                               }

              rd_wrapper.add_child wrap_grid_response_domain nd, qgrid.response_domains.count, i + 1
          end
        end

        unless qgrid.instruction.nil?
          iif = create_reference_string 'd:InterviewerInstructionReference', qgrid.instruction
          qg.add_child iif
        end
      end
    end

    private
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
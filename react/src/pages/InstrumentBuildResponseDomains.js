import React from 'react';
import { useDispatch } from 'react-redux'
import { ResponseDomainNumerics, ResponseDomainTexts, ResponseDomainDatetimes } from '../actions'
import { ResponseDomainNumericForm } from '../components/ResponseDomainNumericForm'
import { ResponseDomainTextForm } from '../components/ResponseDomainTextForm'
import { ResponseDomainDatetimeForm } from '../components/ResponseDomainDatetimeForm'
import { BuildContainer } from '../components/BuildContainer'
import { get } from "lodash";
import { reverse as url } from 'named-urls'
import routes from '../routes'
import { HumanizeObjectType } from '../support/HumanizeObjectType'

const InstrumentBuildResponseDomains = (props) => {
  const dispatch = useDispatch()
  const instrumentId = get(props, "match.params.instrument_id", "")
  const responseDomainId = get(props, "match.params.responseDomainId", null)
  const responseDomainType = get(props, "match.params.responseDomainType", null)

  return (
    <BuildContainer
      instrumentId={instrumentId}
      itemId={responseDomainId}
      itemType={responseDomainType}
      heading={'Response Domains'}
      stateKey={['responseDomainNumerics', 'responseDomainTexts', 'responseDomainDatetimes']}
      objectType={['ResponseDomainText', 'ResponseDomainNumeric', 'ResponseDomainDatetime']}
      fetch={[
        dispatch(ResponseDomainNumerics.all(instrumentId)),
        dispatch(ResponseDomainTexts.all(instrumentId)),
        dispatch(ResponseDomainDatetimes.all(instrumentId))
      ]}
      findSelectedItem={(items, itemId, itemType) => { return Object.values(items).find(item => item.id == itemId && item.type === itemType) || {type: itemType}; }}
      selectionPath={(instrumentId, id, type) => { return url(routes.instruments.instrument.build.responseDomains.show, { instrument_id: instrumentId, responseDomainType: type, responseDomainId: id }) }}
      listItemLabel={(item)=>{return item.label}}
      listItemValue={(item)=>{return HumanizeObjectType(item.type)}}
      formRenderer={(instrumentId, selectedItem) => {
          switch (selectedItem.type) {
            case ('ResponseDomainNumeric'):
              return <ResponseDomainNumericForm responseDomain={selectedItem} instrumentId={instrumentId} />
            case ('ResponseDomainText'):
              return <ResponseDomainTextForm responseDomain={selectedItem} instrumentId={instrumentId} />
            case ('ResponseDomainDatetime'):
              return <ResponseDomainDatetimeForm responseDomain={selectedItem} instrumentId={instrumentId} />
            default:
              return ''
          }
      }}
    />
  );
}

export default InstrumentBuildResponseDomains;

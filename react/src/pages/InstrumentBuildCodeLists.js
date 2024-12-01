import React from 'react';
import { useDispatch } from 'react-redux'
import { useParams } from 'react-router-dom';
import { CodeLists, Categories } from '../actions'
import { CodeListForm } from '../components/CodeListForm'
import { BuildContainer } from '../components/BuildContainer'
import { get } from "lodash";
import { reverse as url } from 'named-urls'
import routes from '../routes'

const InstrumentBuildCodeLists = (props) => {
  const dispatch = useDispatch()
  const { instrument_id: instrumentId, codeListId } = useParams();

  return (
    <BuildContainer
        instrumentId = { instrumentId }
        itemId = { codeListId }
        heading = { 'Code Lists' }
        stateKey = { 'codeLists' }
        findSelectedItem={(items, itemId, itemType) => { return get(items, itemId, { used_by: [], min_responses: 1, max_responses: 1 }); }}
        fetch = { [dispatch(CodeLists.all(instrumentId)), dispatch(Categories.all(instrumentId))]}
        selectionPath = {(instrumentId, id)=>{ return url(routes.instruments.instrument.build.codeLists.show, { instrument_id: instrumentId, codeListId: id }) }}
        formRenderer = {(instrumentId, selectedItem, instrument)=>{ return (
          <CodeListForm codeList={selectedItem} instrumentId={instrumentId} instrument={instrument} />
        )} }
      />
  );
}

export default InstrumentBuildCodeLists;

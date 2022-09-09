import React from 'react';
import { useDispatch } from 'react-redux'
import { QuestionGrids, CodeLists } from '../actions'
import { QuestionGridForm } from '../components/QuestionGridForm'
import { BuildContainer } from '../components/BuildContainer'
import { get } from "lodash";
import { reverse as url } from 'named-urls'
import routes from '../routes'
import { Link } from 'react-router-dom';

const InstrumentBuildQuestionGrids = (props) => {
  const dispatch = useDispatch()
  const instrumentId = get(props, "match.params.instrument_id", "")
  const questionGridId = get(props, "match.params.questionGridId", null);

  return (
    <BuildContainer
      instrumentId={instrumentId}
      itemId={questionGridId}
      heading={'Question Items'}
      headingContent={(instrumentId) => { return (<Link to={url(routes.instruments.instrument.build.questionItems.all, { instrument_id: instrumentId })}>Question Items</Link>) }}
      stateKey={['questionGrids']}
      objectType={['QuestionGrid']}
      fetch={[
        dispatch(CodeLists.all(instrumentId)),
        dispatch(QuestionGrids.all(instrumentId)),
      ]}
      selectionPath={(instrumentId, id, type) => { return url(routes.instruments.instrument.build.questionGrids.show, { instrument_id: instrumentId, questionGridId: id }) }}
      listItemLabel={(item) => { return item.label }}
      listItemValue={(item) => { return '' }}
      formRenderer={(instrumentId, selectedItem) => (
        <QuestionGridForm questionGrid={selectedItem} instrumentId={instrumentId} />
      )}
    />
  );
}

export default InstrumentBuildQuestionGrids;

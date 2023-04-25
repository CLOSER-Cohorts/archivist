import React from 'react';
import { useDispatch } from 'react-redux'
import { QuestionItems } from '../actions'
import { QuestionItemForm } from '../components/QuestionItemForm'
import { BuildContainer } from '../components/BuildContainer'
import { get } from "lodash";
import { reverse as url } from 'named-urls'
import routes from '../routes'
import { Link } from 'react-router-dom';

const InstrumentBuildQuestionItems = (props) => {
  const dispatch = useDispatch()
  const instrumentId = get(props, "match.params.instrument_id", "")
  const questionItemId = get(props, "match.params.questionItemId", null);

  return (
    <BuildContainer
      instrumentId={instrumentId}
      itemId={questionItemId}
      heading={'Question Items'}
      headingContent={(instrumentId)=>{ return (<Link to={url(routes.instruments.instrument.build.questionGrids.all, { instrument_id: instrumentId })}>Question Grids</Link>) }}
      stateKey={['questionItems']}
      objectType={['QuestionItem']}
      fetch={[
        dispatch(QuestionItems.all(instrumentId)),
      ]}
      selectionPath={(instrumentId, id, type) => { return url(routes.instruments.instrument.build.questionItems.show, { instrument_id: instrumentId, questionItemId: id }) }}
      listItemLabel={(item) => { return item.label }}
      listItemValue={(item) => { return '' }}
      formRenderer={(instrumentId, selectedItem, instrument) => (
        <QuestionItemForm questionItem={selectedItem} instrumentId={instrumentId} instrument={instrument} />
      )}
    />
  );
}

export default InstrumentBuildQuestionItems;

import React, {  } from 'react';
import { useDispatch } from 'react-redux'
import { CcQuestions } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { DataTable } from '../components/DataTable'
import { get } from 'lodash'

const InstrumentCcQuestions = (props) => {

  const dispatch = useDispatch()
  const instrumentId = get(props, "match.params.instrument_id", "")

  const actions = (row) => {
    return ''
  }

  const headers = ["ID", "Label", "Base Label", "Response Unit Label"]
  const rowRenderer = (row) => {
    return [row.id, row.label, row.base_label, row.response_unit_label]
  }
  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'CcQuestions'} instrumentId={instrumentId}>
        <DataTable actions={actions}
          fetch={[dispatch(CcQuestions.all(instrumentId))]}
          stateKey={'cc_questions'}
          parentStateKey={instrumentId}
          searchKey={'label'}
          headers={headers}
          rowRenderer={rowRenderer}
          />
      </Dashboard>
    </div>
  );
}

export default InstrumentCcQuestions;

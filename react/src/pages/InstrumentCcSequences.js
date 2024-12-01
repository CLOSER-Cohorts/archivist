import React, {  } from 'react';
import { useDispatch } from 'react-redux'
import { CcSequences } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { DataTable } from '../components/DataTable'
import { useParams } from 'react-router-dom';

const InstrumentCcSequences = (props) => {

  const dispatch = useDispatch()
  const { instrument_id: instrumentId } = useParams();

  const actions = (row) => {
    return ''
  }

  const headers = ["ID", "Literal", "Label"]
  const rowRenderer = (row) => {
    return [row.id, row.literal, row.label]
  }
  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'CcSequences'} instrumentId={instrumentId}>
        <DataTable actions={actions}
          fetch={[dispatch(CcSequences.all(instrumentId))]}
          stateKey={'cc_sequences'}
          parentStateKey={instrumentId}
          searchKey={'label'}
          headers={headers}
          sortKeys={[{ key: 'label', label: 'Label' }, { key: 'id', label: 'ID' }, { key: 'literal', label: 'Literal' }]}
          rowRenderer={rowRenderer}
          />
      </Dashboard>
    </div>
  );
}

export default InstrumentCcSequences;

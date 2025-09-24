import React, {  } from 'react';
import { useDispatch } from 'react-redux'
import { useParams } from 'react-router-dom';
import { CcLoops } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { DataTable } from '../components/DataTable'

const InstrumentCcLoops = (props) => {

  const dispatch = useDispatch()
  const { instrument_id: instrumentId } = useParams();

  const actions = (row) => {
    return ''
  }

  const headers = ["ID", "Label", "Start Value", "End Value", "Loop While"]
  const rowRenderer = (row) => {
    return [row.id, row.label, row.start_val, row.end_val, row.loop_while]
  }
  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'CcLoops'} instrumentId={instrumentId}>
        <DataTable actions={actions}
          fetch={[dispatch(CcLoops.all(instrumentId))]}
          stateKey={'cc_loops'}
          parentStateKey={instrumentId}
          searchKey={'label'}
          headers={headers}
          sortKeys={[{ key: 'label', label: 'Label' }, { key: 'id', label: 'ID' }]}
          rowRenderer={rowRenderer}
          />
      </Dashboard>
    </div>
  );
}

export default InstrumentCcLoops;

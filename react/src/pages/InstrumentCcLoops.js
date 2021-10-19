import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { CcLoops } from '../actions'
import { Dashboard } from '../components/Dashboard'
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
import { DataTable } from '../components/DataTable'
import { get } from 'lodash'

const InstrumentCcLoops = (props) => {

  const dispatch = useDispatch()
  const instrumentId = get(props, "match.params.instrument_id", "")

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
          rowRenderer={rowRenderer}
          />
      </Dashboard>
    </div>
  );
}

export default InstrumentCcLoops;

import React, {  } from 'react';
import { useSelector } from 'react-redux'
import { useParams } from 'react-router-dom';
import { Dashboard } from '../components/Dashboard'
import { InstrumentForm } from '../components/InstrumentForm'
import { get } from 'lodash'

const InstrumentEdit = (props) => {

  const { instrument_id: instrumentId } = useParams();
  const instrument = useSelector(state => get(state.instruments, instrumentId));

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Edit Instrument'}>
        <InstrumentForm instrument={instrument} />
      </Dashboard>
    </div>
  );
}

export default InstrumentEdit;

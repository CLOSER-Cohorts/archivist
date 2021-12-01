import React, {  } from 'react';
import { useDispatch } from 'react-redux'
import { Dashboard } from '../components/Dashboard'
import { InstrumentForm } from '../components/InstrumentForm'

const InstrumentNew = () => {

  const dispatch = useDispatch()

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Instruments'}>
        <InstrumentForm instrument={{}} />
      </Dashboard>
    </div>
  );
}

export default InstrumentNew;

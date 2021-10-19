import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Instrument } from '../actions'
import { Dashboard } from '../components/Dashboard'
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
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

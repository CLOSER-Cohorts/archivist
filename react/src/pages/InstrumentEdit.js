import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Instrument } from '../actions'
import { Dashboard } from '../components/Dashboard'
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
import { InstrumentForm } from '../components/InstrumentForm'
import { get } from 'lodash'

const InstrumentEdit = (props) => {

  const dispatch = useDispatch()

  const instrumentId = get(props, "match.params.instrument_id", "")
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

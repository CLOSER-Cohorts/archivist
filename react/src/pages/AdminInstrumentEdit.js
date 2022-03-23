import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Instrument, Dataset } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { AdminInstrumentForm } from '../components/AdminInstrumentForm'
import { get } from 'lodash'
import { Loader } from '../components/Loader'

const AdminInstrumentEdit = (props) => {

  const dispatch = useDispatch()

  const instrumentId = get(props, "match.params.instrument_id", "")
  const instrument = useSelector(state => get(state.instruments, instrumentId));
  const datasets = useSelector(state => get(state, 'datasets'));

  const [dataLoaded, setDataLoaded] = useState(false);

  useEffect(() => {
    Promise.all([
      dispatch(Instrument.show(instrumentId)),
      dispatch(Dataset.all())
    ]).then(() => {
      setDataLoaded(true)
    });
  }, []);

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Admin Edit Instrument'}>
        {!dataLoaded
          ? <Loader />
          : <AdminInstrumentForm instrument={instrument} datasets={datasets} />
        }
      </Dashboard>
    </div>
  );
}

export default AdminInstrumentEdit;

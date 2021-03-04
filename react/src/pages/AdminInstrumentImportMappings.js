import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Dashboard } from '../components/Dashboard'
import { AdminImportMappingsTable } from '../components/AdminImportMappingsTable'
import { AdminImportMappingsForm } from '../components/AdminImportMappingsForm'
import { Loader } from '../components/Loader'
import { AdminImportMapping } from '../actions'
import { get } from 'lodash';

const AdminInstrumentImportMappings = (props) => {
  const dispatch = useDispatch()
  const type = "Instrument"
  const hint = "You can import multiple Q-V and T-Q mapping files. Only TXT files are accepted."
  const instrumentId = get(props, "match.params.instrumentId", "")

  const onSubmit = (values) => {
      dispatch(AdminImportMapping.create('instruments', instrumentId, values))
  }
  const values = Object.values(useSelector(state => state.instrumentImportMappings));

  const [dataLoaded, setDataLoaded] = useState(false);
  useEffect(() => {
    Promise.all([
      dispatch(AdminImportMapping.all('instruments',instrumentId)),
    ]).then(() => {
      setDataLoaded(true)
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Instruments Import Mappings'}>
        {!dataLoaded
        ? <Loader />
        : (
          <>
            <AdminImportMappingsForm type={type} hint={hint} onSubmit={onSubmit} />
            <AdminImportMappingsTable values={values} />
          </>
        )}
      </Dashboard>
    </div>
  );
}

export default AdminInstrumentImportMappings;

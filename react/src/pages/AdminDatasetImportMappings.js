import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Dashboard } from '../components/Dashboard'
import { AdminImportMappingsTable } from '../components/AdminImportMappingsTable'
import { AdminImportMappingsForm } from '../components/AdminImportMappingsForm'
import { Loader } from '../components/Loader'
import { AdminImportMapping } from '../actions'
import { get } from 'lodash';

const AdminDatasetImportMappings = (props) => {
  const dispatch = useDispatch()
  const type = "Dataset"
  const hint = "You can import multiple T-V and DV mapping files. Only TXT files are accepted."
  const datasetId = get(props, "match.params.datasetId", "")

  const onSubmit = (values) => {
      dispatch(AdminImportMapping.create('datasets', datasetId, {
          imports: Array.from(values.files).map((file) => {
            console.log(file)
            console.log({ file: file, type: values.types[file.name]})
            return { file: file, type: values.types[file.name]}
          })
        }
      ))
  }
  const values = Object.values(useSelector(state => state.datasetImportMappings));

  const [dataLoaded, setDataLoaded] = useState(false);
  useEffect(() => {
    Promise.all([
      dispatch(AdminImportMapping.all('datasets',datasetId)),
    ]).then(() => {
      setDataLoaded(true)
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Datasets Import Mappings'}>
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

export default AdminDatasetImportMappings;

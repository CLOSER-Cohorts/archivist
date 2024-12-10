import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { useParams } from 'react-router-dom';
import { Dataset } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { DatasetForm } from '../components/DatasetForm'
import { get } from 'lodash'
import { Loader } from '../components/Loader'

const DatasetEdit = (props) => {

  const dispatch = useDispatch()

  const { dataset_id: datasetId } = useParams();
  console.log(useSelector(state => state.datasets))
  const dataset = useSelector(state => get(state.datasets, datasetId));

  const [dataLoaded, setDataLoaded] = useState(false);

  useEffect(() => {
    Promise.all([
      dispatch(Dataset.show(datasetId))
    ]).then(() => {
      setDataLoaded(true)
    });
    
  }, []);

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Edit Dataset'}>
        {!dataLoaded
          ? <Loader />
          : (
            <DatasetForm dataset={dataset} />
          )}
      </Dashboard>
    </div>
  );
}

export default DatasetEdit;

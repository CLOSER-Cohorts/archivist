import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Dataset } from '../actions'
import { Dashboard } from '../components/Dashboard'
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
import { DatasetForm } from '../components/DatasetForm'
import { get } from 'lodash'
import { Loader } from '../components/Loader'

const DatasetEdit = (props) => {

  const dispatch = useDispatch()

  const datasetId = get(props, "match.params.dataset_id", "")
  console.log(useSelector(state => state.datasets))
  const dataset = useSelector(state => get(state.datasets, datasetId));

  const [dataLoaded, setDataLoaded] = useState(false);

  useEffect(() => {
    Promise.all([
      dispatch(Dataset.show(datasetId))
    ]).then(() => {
      setDataLoaded(true)
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
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

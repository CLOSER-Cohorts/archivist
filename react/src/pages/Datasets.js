import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Dataset } from '../actions'
import { Dashboard } from '../components/Dashboard'
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
import { DataTable } from '../components/DataTable'

const Datasets = () => {

  const dispatch = useDispatch()

  const actions = (row) => {
    return (
      <>
        <Button variant="outlined">
          <Link to={url('/datasets/:dataset_id', { dataset_id: row.id })}>View</Link>
        </Button>
      </>
    )
  }

  const headers = ["ID", "Name", "Variables", "Q-V Mappings", "DV Mappings", "Study"]
  const rowRenderer = (row) => {
    return [row.id, row.name, row.variables, row.qvs, row.dvs, row.study]
  }
  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Datasets'}>
        <DataTable actions={actions}
          fetch={[dispatch(Dataset.all())]}
          stateKey={'datasets'}
          searchKey={'name'}
          headers={headers}
          rowRenderer={rowRenderer}
          />
      </Dashboard>
    </div>
  );
}

export default Datasets;

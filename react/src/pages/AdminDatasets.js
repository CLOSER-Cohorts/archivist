import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Dataset } from '../actions'
import { Dashboard } from '../components/Dashboard'
import ButtonGroup from '@material-ui/core/ButtonGroup';
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
import { DataTable } from '../components/DataTable'

const AdminDatasets = () => {

  const dispatch = useDispatch()

  const actions = (row) => {
    return (
      <ButtonGroup variant="outlined">
        <Button>
          Edit
        </Button>
        <Button>
          <Link to={url(routes.admin.datasets.importMappings, { datasetId: row.id })}>
            Import Mappings
          </Link>
        </Button>
        <Button>
          DV
        </Button>
        <Button>
          Topics
        </Button>
        <Button>
          <Link to={url(routes.admin.datasets.importMappings, { datasetId: row.id })}>
            View Imports
          </Link>
        </Button>
        <Button>
          Delete
        </Button>
       </ButtonGroup>
    )
  }

  const headers = ["ID", "Name", "Study"]
  const rowRenderer = (row) => {
    return [row.id, row.name, row.study]
  }
  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Admin Datasets'}>
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

export default AdminDatasets;

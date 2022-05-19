import React from 'react';
import { useDispatch } from 'react-redux'
import { Dataset, AdminDataset } from '../actions'
import { Dashboard } from '../components/Dashboard'
import ButtonGroup from '@material-ui/core/ButtonGroup';
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
import { DataTable } from '../components/DataTable'
import { ConfirmationModal } from '../components/ConfirmationModal'

const AdminDatasets = () => {

  const dispatch = useDispatch()

  const deleteDataset = (datasetId) => {
    dispatch(AdminDataset.delete(datasetId));
  }

  const actions = (row) => {
    return (
      <ButtonGroup variant="outlined">
        <Button>
          <Link to={url(routes.admin.datasets.dataset.show, { dataset_id: row.id })}>View</Link>
        </Button>
        <Button>
          <Link to={url(routes.datasets.dataset.edit, { dataset_id: row.id })}>Edit</Link>
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
        <ConfirmationModal objectType={'dataset'} onConfirm={() => { deleteDataset(row.id) }} />
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
          searchKeys={['id', 'filename', 'name']}
          headers={headers}
          filters={[{ key: 'study', label: 'Study', options: [] }]}
          rowRenderer={rowRenderer}
          />
      </Dashboard>
    </div>
  );
}

export default AdminDatasets;

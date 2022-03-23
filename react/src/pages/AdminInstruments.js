import React, {  } from 'react';
import { useDispatch } from 'react-redux'
import { Instrument, AdminInstrument } from '../actions'
import { Dashboard } from '../components/Dashboard'
import ButtonGroup from '@material-ui/core/ButtonGroup';
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
import { DataTable } from '../components/DataTable'
import { ConfirmationModal } from '../components/ConfirmationModal'
import AddCircleOutlineIcon from '@material-ui/icons/AddCircleOutline';

const AdminInstruments = () => {

  const dispatch = useDispatch()

  const deleteInstrument = (instrumentId) => {
    dispatch(AdminInstrument.delete(instrumentId));
  }

  const clearCache = (instrumentId) => {
    dispatch(AdminInstrument.clearCache(instrumentId));
  }

  const actions = (row) => {
    return (
      <>
        <ButtonGroup variant="outlined">
          <Button>
            <Link to={url(routes.admin.instruments.instrument.edit, { instrument_id: row.prefix })}>Edit</Link>
          </Button>
          <Button>
            <Link to={url(routes.admin.instruments.instrument.datasets, { instrument_id: row.prefix })}>Datasets</Link>
          </Button>
          <Button>
            <Link to={url(routes.admin.instruments.importMappings, { instrumentId: row.id })}>
              Import Mappings
            </Link>
          </Button>
          <Button>
            <Link to={url(routes.admin.instruments.importMappings, { instrumentId: row.id })}>
              View Imports
            </Link>
          </Button>
          <Button onClick={()=>{ clearCache(row.id) }}>
            Clear Cache
          </Button>
          <ConfirmationModal textToConfirm={row.prefix} key={'prefix'} objectType={'instrument'} onConfirm={() => { deleteInstrument(row.prefix) }}/>
        </ButtonGroup>
      </>
    )
  }

  const headers = ["ID", "Prefix", "Study"]
  const rowRenderer = (row) => {
    return [row.id, row.prefix, row.study]
  }
  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Admin Instruments'}>
        <Button variant="contained" color="primary">
          <Link to={url(routes.instruments.new)}><AddCircleOutlineIcon /> Add new Instrument</Link>
        </Button>
        <DataTable actions={actions}
          fetch={[dispatch(Instrument.all())]}
          stateKey={'instruments'}
          searchKeys={['id', 'prefix', 'label']}
          headers={headers}
          filters={[{ key: 'study', label: 'Study', options: [] }]}
          sortKeys={[{ key: 'id', label: 'ID' }, { key: 'prefix', label: 'Prefix' }, { key: 'study', label: 'Study' }, { key: 'ccs', label: 'Control Constructs' }]}
          rowRenderer={rowRenderer}
          />
      </Dashboard>
    </div>
  );
}

export default AdminInstruments;

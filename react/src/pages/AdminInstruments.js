import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Instrument } from '../actions'
import { Dashboard } from '../components/Dashboard'
import ButtonGroup from '@material-ui/core/ButtonGroup';
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
import { DataTable } from '../components/DataTable'
import AddCircleOutlineIcon from '@material-ui/icons/AddCircleOutline';

const AdminInstruments = () => {

  const dispatch = useDispatch()

  const actions = (row) => {
    return (
      <>
        <ButtonGroup variant="outlined">
          <Button>
            <Link to={url(routes.instruments.instrument.edit, { instrument_id: row.prefix })}>Edit</Link>
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
          <Button>
            Clear Cache
          </Button>
          <Button>
            Delete
          </Button>
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
          searchKey={'prefix'}
          headers={headers}
          rowRenderer={rowRenderer}
          />
      </Dashboard>
    </div>
  );
}

export default AdminInstruments;

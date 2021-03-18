import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Instrument } from '../actions'
import { Dashboard } from '../components/Dashboard'
import Button from '@material-ui/core/Button';
import ButtonGroup from '@material-ui/core/ButtonGroup';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
import { DataTable } from '../components/DataTable'

const Instruments = () => {

  const dispatch = useDispatch()

  const actions = (row) => {
    return (
      <>
        <ButtonGroup variant="outlined">
          <Button>
            <Link to={url(routes.instruments.instrument.edit, { instrument_id: row.prefix })}>Edit</Link>
          </Button>
          <Button>
            <Link to={url(routes.instruments.instrument.show, { instrument_id: row.prefix })}>View</Link>
          </Button>
          <Button>
            <Link to={url(routes.instruments.instrument.build.show, { instrument_id: row.prefix })}>Build</Link>
          </Button>
          <Button>
            <Link to={url(routes.instruments.instrument.map.show, { instrument_id: row.prefix })}>Map</Link>
          </Button>
        </ButtonGroup>
      </>
    )
  }

  const headers = ["ID", "Prefix", "Control Contructs", "Q-V Mappings", "Study"]
  const rowRenderer = (row) => {
    return [row.id, row.prefix, row.ccs, row.qvs, row.study]
  }
  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Instruments'}>
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

export default Instruments;

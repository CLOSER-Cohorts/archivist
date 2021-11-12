import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Dataset } from '../actions'
import { Dashboard } from '../components/Dashboard'
import Button from '@material-ui/core/Button';
import ButtonGroup from '@material-ui/core/ButtonGroup';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
import { DataTable } from '../components/DataTable'

const Datasets = () => {

  const dispatch = useDispatch()

  const actions = (row) => {
    return (
      <>
        <ButtonGroup variant="outlined">
          <Button>
            <Link to={url(routes.datasets.dataset.edit, { dataset_id: row.id })}>Edit</Link>
          </Button>
          <Button>
            <Link to={url('/datasets/:dataset_id', { dataset_id: row.id })}>View</Link>
          </Button>
        </ButtonGroup>
      </>
    )
  }

  const headers = ["ID", "Name", "Variables", "Q-V Mappings", "DV Mappings", "Study", "Instruments"]
  const rowRenderer = (row) => {
    return [row.id, row.name, row.variables, row.qvs, row.dvs, row.study, row.instruments.map((instrument) => { return <Link to={url(routes.instruments.instrument.show, { instrument_id: instrument.prefix })}>{instrument.prefix}</Link> })]
  }
  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Datasets'}>
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

export default Datasets;

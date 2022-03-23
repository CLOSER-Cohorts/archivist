import React, {  } from 'react';
import { useDispatch } from 'react-redux'
import { Instrument } from '../actions'
import { Dashboard } from '../components/Dashboard'
import Button from '@material-ui/core/Button';
import ButtonGroup from '@material-ui/core/ButtonGroup';
import Chip from '@material-ui/core/Chip';
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
          { !row.signed_off && (
            <Button>
              <Link to={url(routes.instruments.instrument.edit, { instrument_id: row.prefix })}>Edit</Link>
            </Button>
          )}
          <Button>
            <Link to={url(routes.instruments.instrument.show, { instrument_id: row.prefix })}>View</Link>
          </Button>
          {!row.signed_off && (
            <Button>
              <Link to={url(routes.instruments.instrument.build.show, { instrument_id: row.prefix })}>Build</Link>
            </Button>
          )}
          <Button>
            <Link to={url(routes.instruments.instrument.map.show, { instrument_id: row.prefix })}>Map</Link>
          </Button>
        </ButtonGroup>
      </>
    )
  }

  const headers = ["ID", "Prefix", "Control Contructs", "Q-V Mappings", "Study", "Datasets"]
  const rowRenderer = (row) => {
    return [row.id, row.prefix, row.ccs, row.qvs, row.study, row.datasets.map((dataset) => { return <Link to={url('/datasets/:dataset_id', { dataset_id: dataset.id })}><Chip label={dataset.instance_name} /></Link>})]
  }
  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Instruments'}>
        <DataTable actions={actions}
          fetch={[dispatch(Instrument.all())]}
          stateKey={'instruments'}
          searchKeys={['id','prefix', 'label']}
          headers={headers}
          filters={[{ key: 'study', label: 'Study', options: [] }]}
          sortKeys={[{ key: 'id', label: 'ID' }, { key: 'prefix', label: 'Prefix' }, { key: 'study', label: 'Study' }, { key: 'ccs', label: 'Control Constructs' }]}
          rowRenderer={rowRenderer}
          />
      </Dashboard>
    </div>
  );
}

export default Instruments;

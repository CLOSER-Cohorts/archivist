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
import { isNil } from 'lodash'
import Snackbar from '@material-ui/core/Snackbar';
import MuiAlert from '@material-ui/lab/Alert';

function Alert(props) {
  return <MuiAlert elevation={6} variant="filled" {...props} />;
}

const AdminInstrumentExports = () => {

  const dispatch = useDispatch()
  const [message, setMessage] = useState()

  const handleClick = (id)=>{
    dispatch(Instrument.export(id))
    setMessage('Creating new export')
  }

  const handleClose = (event, reason) => {
    if (reason === 'clickaway') {
      return;
    }
    setMessage(undefined);
  };

  const actions = (row) => {
    return (
      <>
        <ButtonGroup variant="outlined">
          {!isNil(row.export_url) && (
            <Button>
              <a target={'_blank'} href={process.env.REACT_APP_API_HOST + row.export_url}>Download export</a>
            </Button>
          )}
          <Button>
            <Link onClick={()=>{handleClick(row.id)}}>Create new export</Link>
          </Button>
        </ButtonGroup>
      </>
    )
  }

  const headers = ["ID", "Prefix", "Study", "Export date"]
  const rowRenderer = (row) => {
    return [row.id, row.prefix, row.study, row.export_time]
  }
  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Admin Instrument Exports'}>
        <Snackbar anchorOrigin={{ vertical: 'top', horizontal: 'center'}} open={!isNil(message)} autoHideDuration={6000} onClose={handleClose}>
          <Alert onClose={handleClose}>
            {message}
          </Alert>
        </Snackbar>
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

export default AdminInstrumentExports;

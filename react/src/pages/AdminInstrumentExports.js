import React, { useState } from 'react';
import { useDispatch } from 'react-redux'
import { Instrument } from '../actions'
import { Dashboard } from '../components/Dashboard'
import ButtonGroup from '@material-ui/core/ButtonGroup';
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';
import { DataTable } from '../components/DataTable'
import { isNil } from 'lodash'
import Snackbar from '@material-ui/core/Snackbar';
import MuiAlert from '@material-ui/lab/Alert';
import CloudDownloadIcon from '@material-ui/icons/CloudDownload';

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

  const handleClickCompleteExport = (id) => {
    dispatch(Instrument.export_complete(id))
    setMessage('Creating new complete export')
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
          <Button>
            <Link onClick={()=>{handleClick(row.id)}}>Create new export</Link>
          </Button>
          <Button>
            <Link onClick={() => { handleClickCompleteExport(row.id) }}>Create new complete export</Link>
          </Button>
          {!isNil(row.export_url) && (
            <span style={{ cursor: 'not-allowed' }}>
              <Button variant="contained" color="primary">
                <a style={{ color: 'white', textDecoration: 'none' }} target={'_blank'} href={process.env.REACT_APP_API_HOST + row.export_url}><CloudDownloadIcon /><br />Download export <br />{row.export_time}</a>
              </Button>
            </span>
          )}
          {!isNil(row.export_complete_url) && (
            <Button variant="contained" color="primary">
              <a style={{ color: 'white', textDecoration: 'none' }} target={'_blank'} href={process.env.REACT_APP_API_HOST + row.export_complete_url}><CloudDownloadIcon /><br />Download complete export <br />{row.export_complete_time}</a>
            </Button>
          )}
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

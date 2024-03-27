import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Instrument, Dataset, AdminInstrument } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { get } from 'lodash'
import { Loader } from '../components/Loader'
import TextField from '@material-ui/core/TextField';
import Autocomplete from '@material-ui/lab/Autocomplete';
import { ObjectStatusBar } from '../components/ObjectStatusBar'
import { makeStyles } from '@material-ui/core/styles';
import { ObjectColour } from '../support/ObjectColour'

import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemAvatar from '@material-ui/core/ListItemAvatar';
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction';
import ListItemText from '@material-ui/core/ListItemText';
import Avatar from '@material-ui/core/Avatar';
import IconButton from '@material-ui/core/IconButton';
import StorageIcon from '@material-ui/icons/Storage';
import DeleteIcon from '@material-ui/icons/Delete';

import {
  Paper
} from '@material-ui/core';

const useStyles = makeStyles({
  table: {
    minWidth: 650,
  },
  paper: {
    boxShadow: `5px 5px 15px 5px  #${ObjectColour('statement')}`
  }
});

const AdminInstrumentDatasetForm = (props) => {
  const {datasets, instrument} = props;

  const [selectedDatasets, setSelectedDatasets] = React.useState([]);

  const dispatch = useDispatch();

  const classes = useStyles();

  const handleDelete = (id) => {
    dispatch(AdminInstrument.datasets.delete(instrument.id, id))
  }

  const handleChange = (event, value, reason) => {
    dispatch(AdminInstrument.datasets.create(instrument.id, value[0].id))
  }

  return (
    <div style={{ padding: 16, margin: 'auto', maxWidth: 1000 }}>
      <ObjectStatusBar id={instrument.id || 'new'} type={'Instrument'} />
      <Paper style={{ padding: 16 }} className={classes.paper}>
        <h1>Datasets linked to {instrument.label}</h1>
        <List>
          {instrument.datasets.map((dataset) => (
            <ListItem>
              <ListItemAvatar>
                <Avatar>
                  <StorageIcon />
                </Avatar>
              </ListItemAvatar>
              <ListItemText
                primary={dataset.name} secondary={`ID #${dataset.id}`}
              />
              <ListItemSecondaryAction>
                <IconButton edge="end" aria-label="delete">
                  <DeleteIcon onClick={() => { handleDelete(dataset.id)}}/>
                </IconButton>
              </ListItemSecondaryAction>
            </ListItem>
          ))}
        </List>
        <Autocomplete
          multiple
          id="combo-box-demo"
          value={selectedDatasets}
          onChange={handleChange}
          options={Object.values(datasets)}
          getOptionLabel={(option) => `${option.study} - ${option.name} (ID #${option.id})`}
          style={{ width: '100%' }}
          renderInput={(params) => <TextField {...params} label="Add dataset" variant="outlined" />}
        />
      </Paper>
    </div>
  )
}

const AdminInstrumentDatasetLink = (props) => {

  const dispatch = useDispatch()

  const instrumentId = get(props, "match.params.instrument_id", "")
  const instrument = useSelector(state => get(state.instruments, instrumentId));
  const datasets = useSelector(state => get(state, 'datasets'));

  const [dataLoaded, setDataLoaded] = useState(false);

  useEffect(() => {
    Promise.all([
      dispatch(Instrument.show(instrumentId)),
      dispatch(Dataset.all())
    ]).then(() => {
      setDataLoaded(true)
    });
  }, []);

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Admin Link Instrument to Datasets'}>
        {!dataLoaded
          ? <Loader />
          : <AdminInstrumentDatasetForm instrument={instrument} datasets={datasets} />
        }
      </Dashboard>
    </div>
  );
}

export default AdminInstrumentDatasetLink;

import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { CodeLists, Categories } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { CodeListForm } from '../components/CodeListForm'
import { CreateNewBuildObjectButtons } from '../components/CreateNewBuildObjectButtons'
import { get, isNil } from "lodash";
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/Paper';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction';
import ListItemText from '@material-ui/core/ListItemText';
import Chip from '@material-ui/core/Chip';
import { useHistory } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
import ChevronLeftIcon from '@material-ui/icons/ChevronLeft';
import ChevronRightIcon from '@material-ui/icons/ChevronRight';

import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles((theme) => ({
  root: {
    width: '100%',
    backgroundColor: theme.palette.background.paper
  },
  control: {
    width: '100%',
    padding: theme.spacing(2),
  },
  truncate: {
    width: 70,
    'white-space': 'nowrap',
    overflow: 'hidden',
    'text-overflow': 'ellipsis'
  },
  list: {
    height: 1500,
    overflow: 'hidden',
    'overflow': 'scroll',
  },
  expandable: {
    marginTop: '20px',
  }

}));

export const BuildContainer = (props) => {
  let history = useHistory();

  const { instrumentId, selectionPath=()=>{}, heading="Code Lists", itemId, objectType="CodeList", stateKey = "codeLists", fetch = [], formRenderer=()=>{}} = props;

  const dispatch = useDispatch()
  const classes = useStyles();

  console.log(stateKey)
  let values = useSelector(state => state[stateKey]);
  console.log(values)
  const items = useSelector(state => get(values, instrumentId, {}));
  console.log(items)
  console.log(Object.values(items))
  const selectedItem = get(items, itemId, { used_by: [], min_responses: 1, max_responses: 1 })

  const [dataLoaded, setDataLoaded] = useState(false);

  useEffect(() => {
    Promise.all(fetch).then(() => {
      setDataLoaded(true)
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const BuildListItem = (props) => {
    const { label, value, id } = props
    const classes = useStyles();

    return (
      <ListItem>
        <ListItemText className= { classes.truncate } primary = { label } onClick = {()=>{ handleItemSelection(id) }}/>
        < ListItemSecondaryAction ><Chip label={ value } /></ListItemSecondaryAction>
      </ListItem>
    )
  }

  const handleItemSelection = (id) => {
    console.log(id)
    console.log(instrumentId)
    console.log(selectionPath(instrumentId, id))
    const path = selectionPath(instrumentId, id)
    history.push(path);
  }

  const Expandable = () => {
    const classes = useStyles();

    return (expanded) ? (<ChevronLeftIcon className= { classes.expandable } onClick = {() => { setExpanded(!expanded) }} />) : (<ChevronRightIcon className={classes.expandable} onClick={() => { setExpanded(!expanded) }} / >)
  }

  const [expanded, setExpanded] = useState(false);

  return (
    <div style= {{ height: 500, width: '100%' }}>
      <Dashboard title={ instrumentId } instrumentId = { instrumentId } >
        <Grid container spacing = { 3} >
          <Grid item xs = {(expanded) ? 8 : 2 }>
            <Paper className={ classes.control }>
              <Grid container >
                <Grid item xs = { 11} > <h2>{heading}</h2></Grid >
                <Grid item xs = { 1} > <Expandable /></Grid >
              </Grid>
              < CreateNewBuildObjectButtons instrumentId = { instrumentId } objectTypes = { [objectType]} />
              <List dense={ true } className = { classes.list } >
                  {
                  Object.values(items).map((item) => {
                    return (
                      <BuildListItem label= { item.label } value = { item.used_by.length } id = { item.id } />
                )
                })}
              </List>
            </Paper>
          </Grid>
          < Grid item xs = {(expanded) ? 4 : 10}>
            {!isNil(selectedItem) && formRenderer(instrumentId, selectedItem)}
          </Grid>
        </Grid>
      </Dashboard>
    </div>
    );
}


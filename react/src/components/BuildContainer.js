import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { CodeLists, Categories } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { CodeListForm } from '../components/CodeListForm'
import { CreateNewBuildObjectButtons } from '../components/CreateNewBuildObjectButtons'
import { get, isNil, forEach } from "lodash";
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
import { Loader } from '../components/Loader'

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

  const { instrumentId, selectionPath = () => { }, heading = "Code Lists", itemId, itemType, objectType = "CodeList", stateKey = "codeLists", fetch = [], formRenderer = () => { }, defaultValues = { used_by: [], min_responses: 1, max_responses: 1 }} = props;
  const { findSelectedItem = (items, itemId, itemType) => { return get(items, itemId, {}) }, listItemLabel = (item) => { return item.label }, listItemValue = (item) => { return item.used_by.length }, headingContent = (instrumentId) => { return '' } } = props;
  const dispatch = useDispatch()
  const classes = useStyles();

  const mergedItems = (keys, selector) => {
    var items = {};

    forEach([keys].flat(), (key)=>{
      items = {...items, ...get(selector(state => state[key]), instrumentId, {})}
    })

    return items;
  }

  const items = mergedItems(stateKey, useSelector)
  const selectedItem = findSelectedItem(items, itemId, itemType)
  const [dataLoaded, setDataLoaded] = useState(false);

  useEffect(() => {
    Promise.all(fetch).then(() => {
      setDataLoaded(true)
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const BuildListItem = (props) => {
    const { label, value, id, type } = props
    const classes = useStyles();

    return (
      <ListItem>
        <ListItemText className= { classes.truncate } primary = { label } onClick = {()=>{ handleItemSelection(id, type) }}/>
        { value !== '' && (
          < ListItemSecondaryAction ><Chip label={value} /></ListItemSecondaryAction>
        )}
      </ListItem>
    )
  }

  const handleItemSelection = (id, type=undefined) => {
    const path = selectionPath(instrumentId, id, type)
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
          <Grid item xs = {(expanded) ? 6 : 3 }>
            <Paper className={ classes.control }>
              <Grid container >
                <Grid item xs = { 11} > <h2>{heading} {headingContent(instrumentId)}</h2></Grid >
                <Grid item xs = { 1} > <Expandable /></Grid >
              </Grid>
              < CreateNewBuildObjectButtons instrumentId = { instrumentId } objectTypes = { [objectType].flat()} />
              {!dataLoaded
                ? <Loader />
                : (
                  <List dense={true} className={classes.list} >
                    {
                      Object.values(items).sort((a, b) => a.label.localeCompare(b.label)).map((item) => {
                        return (
                          <BuildListItem label={listItemLabel(item)} value={listItemValue(item)} id={item.id} type={item.type} />
                        )
                      })}
                  </List>
                )}
            </Paper>
          </Grid>
          < Grid item xs = {(expanded) ? 6 : 9}>
            {!isNil(selectedItem) && formRenderer(instrumentId, selectedItem)}
          </Grid>
        </Grid>
      </Dashboard>
    </div>
    );
}


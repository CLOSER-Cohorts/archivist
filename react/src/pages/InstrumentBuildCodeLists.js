import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { CodeLists, Categories } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { CodeListForm } from '../components/CodeListForm'
import { CreateNewBuildObjectButtons } from '../components/CreateNewBuildObjectButtons'
import { get, isNil } from "lodash";
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/Paper';
import Divider from '@material-ui/core/Divider';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction';
import ListItemText from '@material-ui/core/ListItemText';
import Chip from '@material-ui/core/Chip';
import { useHistory } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'

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
  }
}));

const InstrumentBuildCodeLists = (props) => {
  let history = useHistory();

  const dispatch = useDispatch()
  const classes = useStyles();
  const codeListId = get(props, "match.params.codeListId", null);

  const instrumentId = get(props, "match.params.instrument_id", "")
  const codeLists = useSelector(state => get(state.codeLists, instrumentId, {}));
  const selectedCodeList = get(codeLists, codeListId, {used_by: [], min_responses: 1, max_responses: 1})

  useEffect(() => {
    dispatch(CodeLists.all(instrumentId));
    dispatch(Categories.all(instrumentId));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  const CodeListItem = (props) => {
    const {label, value, id} = props
    const classes = useStyles();

    return (
      <ListItem>
        <ListItemText
          className={classes.truncate} primary={label} onClick={()=>{handleCodeListSelection(id)}}/>
        <ListItemSecondaryAction>
          <Chip label={value} />
        </ListItemSecondaryAction>
      </ListItem>
    )
  }

  const handleCodeListSelection = (id) => {
    const path = url(routes.instruments.instrument.build.codeLists.show, { instrument_id: instrumentId, codeListId: id })
    history.push(path);
  }

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={instrumentId} instrumentId={instrumentId}>
        <Grid container spacing={3}>
          <Grid item xs={2}>
            <Paper className={classes.control}>
              <h2>Code Lists</h2>
              <CreateNewBuildObjectButtons instrumentId={instrumentId} objectTypes={['CodeList']} />
              <List dense={true} className={classes.list}>
                {Object.values(codeLists).map((codeList) => {
                  return (
                    <CodeListItem label={codeList.label} value={codeList.used_by.length} id={codeList.id} />
                  )
                })}
              </List>
            </Paper>
          </Grid>
          <Grid item xs={10}>
              {!isNil(selectedCodeList) && (
                <CodeListForm codeList={selectedCodeList} instrumentId={instrumentId} />
              )}
          </Grid>
        </Grid>
      </Dashboard>
    </div>
  );
}

export default InstrumentBuildCodeLists;

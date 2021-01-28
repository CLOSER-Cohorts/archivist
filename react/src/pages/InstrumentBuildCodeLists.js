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
  side: {
    position: 'absolute',
    width: '50%',
  },
  control: {
    width: '100%',
    padding: theme.spacing(2),
  }
}));

const InstrumentBuildCodeLists = (props) => {
  let history = useHistory();

  const dispatch = useDispatch()
  const classes = useStyles();
  const codeListId = get(props, "match.params.codeListId", null);

  const instrumentId = get(props, "match.params.instrument_id", "")
  const codeLists = useSelector(state => get(state.codeLists, instrumentId, {}));
  const selectedCodeList = get(codeLists, codeListId, {used_by: []})

  useEffect(() => {
    dispatch(CodeLists.all(instrumentId));
    dispatch(Categories.all(instrumentId));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  const CodeListItem = (props) => {
    const {label, value, id} = props
    return (
      <ListItem>
        <ListItemText
          primary={label} onClick={()=>{handleCodeListSelection(id)}}/>
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
      <Dashboard title={instrumentId}>
        <Grid container spacing={3}>
          <Grid item xs={4}>
            <Paper className={classes.control}>
              <h2>Code Lists</h2>
              <CreateNewBuildObjectButtons instrumentId={instrumentId} objectTypes={['CodeList']} />
              <List dense={true}>
                {Object.values(codeLists).map((codeList) => {
                  return (
                    <CodeListItem label={codeList.label} value={codeList.used_by.length} id={codeList.id} />
                  )
                })}
              </List>
            </Paper>
          </Grid>
          <Grid item xs={8}>
            <Paper className={classes.side}>
              {!isNil(selectedCodeList) && (
                <CodeListForm codeList={selectedCodeList} instrumentId={instrumentId} />
              )}
            </Paper>
          </Grid>
        </Grid>
      </Dashboard>
    </div>
  );
}

export default InstrumentBuildCodeLists;

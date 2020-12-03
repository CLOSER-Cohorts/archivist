import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { CodeLists } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { get, isEmpty, isNil } from "lodash";
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/Paper';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemAvatar from '@material-ui/core/ListItemAvatar';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction';
import ListItemText from '@material-ui/core/ListItemText';
import Chip from '@material-ui/core/Chip';

import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles((theme) => ({
  root: {
    width: '100%',
    backgroundColor: theme.palette.background.paper
  },
  control: {
    width: '100%',
    padding: theme.spacing(2),
  }
}));

const InstrumentBuildCodeLists = (props) => {

  const dispatch = useDispatch()
  const classes = useStyles();
  const [codeListId, setcodeListId] = React.useState(get(props, "match.params.codeListId", null));

  const instrumentId = get(props, "match.params.instrument_id", "")
  const codeLists = useSelector(state => get(state.codeLists, instrumentId, {}));
  useEffect(() => {
    dispatch(CodeLists.all(instrumentId));
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
    setcodeListId(id)
  }

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={instrumentId}>
        <Grid container spacing={3}>
          <Grid item xs={4}>
            <Paper className={classes.control}>
              <h2>Code Lists</h2>
              <List dense={true}>
                {Object.values(codeLists).map((codeList) => {
                  console.log(codeList)
                  return <CodeListItem label={codeList.label} value={codeList.used_by.length} id={codeList.id} />
                })}
              </List>
            </Paper>
          </Grid>
          <Grid item xs={8}>
            <Paper className={classes.control}>
              <h2>Code List</h2>
              {codeListId}
            </Paper>
          </Grid>
        </Grid>
      </Dashboard>
    </div>
  );
}

export default InstrumentBuildCodeLists;

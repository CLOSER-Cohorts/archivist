import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { ResponseDomainNumerics } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { ResponseDomainForm } from '../components/ResponseDomainForm'
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

const InstrumentBuildResponseDomains = (props) => {
  let history = useHistory();

  const dispatch = useDispatch()
  const classes = useStyles();
  const [responseDomainId, setresponseDomainId] = React.useState(get(props, "match.params.responseDomainId", null));

  const instrumentId = get(props, "match.params.instrument_id", "")
  const responseDomainNumerics = useSelector(state => get(state.responseDomainNumerics, instrumentId, {}));
  console.log(responseDomainNumerics)
  const responseDomains = Object.values(responseDomainNumerics)
  console.log(responseDomains)
  const selectedResponseDomain = get(responseDomains, responseDomainId, {used_by: []})

  useEffect(() => {
    dispatch(ResponseDomainNumerics.all(instrumentId));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  const ResponseDomainItem = (props) => {
    const {label, value, id} = props
    return (
      <ListItem>
        <ListItemText
          primary={label} onClick={()=>{handleResponseDomainSelection(id)}}/>
        <ListItemSecondaryAction>
          <Chip label={value} />
        </ListItemSecondaryAction>
      </ListItem>
    )
  }

  const handleResponseDomainSelection = (id) => {
    const path = url(routes.instruments.instrument.build.responseDomains.show, { instrument_id: instrumentId, responseDomainId: id })
    history.push(path);
    setresponseDomainId(id)
  }

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={instrumentId}>
        <Grid container spacing={3}>
          <Grid item xs={4}>
            <Paper className={classes.control}>
              <h2>Response Domains</h2>
              <List dense={true}>
                {Object.values(responseDomains).map((responseDomain) => {
                  return <ResponseDomainItem label={responseDomain.label} value={responseDomain.type} id={responseDomain.id} />
                })}
              </List>
            </Paper>
          </Grid>
          <Grid item xs={8}>
            <Paper className={classes.control}>
              {!isNil(selectedResponseDomain) && (
                <ResponseDomainForm responseDomain={selectedResponseDomain} instrumentId={instrumentId} />
              )}
            </Paper>
          </Grid>
        </Grid>
      </Dashboard>
    </div>
  );
}

export default InstrumentBuildResponseDomains;

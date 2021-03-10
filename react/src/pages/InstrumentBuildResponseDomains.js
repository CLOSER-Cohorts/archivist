import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { ResponseDomainNumerics, ResponseDomainTexts, ResponseDomainDatetimes } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { ResponseDomainNumericForm } from '../components/ResponseDomainNumericForm'
import { ResponseDomainTextForm } from '../components/ResponseDomainTextForm'
import { ResponseDomainDatetimeForm } from '../components/ResponseDomainDatetimeForm'
import { CreateNewBuildObjectButtons } from '../components/CreateNewBuildObjectButtons'
import { get } from "lodash";
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
  side: {
    position: 'absolute',
    width: '50%',
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

  const instrumentId = get(props, "match.params.instrument_id", "")
  const responseDomainId = get(props, "match.params.responseDomainId", null)
  const responseDomainType = get(props, "match.params.responseDomainType", null)

  const responseDomainNumerics = useSelector(state => get(state.responseDomainNumerics, instrumentId, {}));
  const responseDomainTexts = useSelector(state => get(state.responseDomainTexts, instrumentId, {}));
  const responseDomainDatetimes = useSelector(state => get(state.responseDomainDatetimes, instrumentId, {}));

  const responseDomains = [...Object.values(responseDomainNumerics), ...Object.values(responseDomainTexts), ...Object.values(responseDomainDatetimes)]

  const selectedResponseDomain = responseDomains.find(responseDomain => responseDomain.id === responseDomainId && responseDomain.type === responseDomainType) || {};

  useEffect(() => {
    dispatch(ResponseDomainNumerics.all(instrumentId));
    dispatch(ResponseDomainTexts.all(instrumentId));
    dispatch(ResponseDomainDatetimes.all(instrumentId));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  const ResponseDomainItem = (props) => {
    const {label, type, id} = props
    return (
      <ListItem>
        <ListItemText
          primary={label} onClick={()=>{handleResponseDomainSelection(type,id)}}/>
        <ListItemSecondaryAction>
          <Chip label={type} />
        </ListItemSecondaryAction>
      </ListItem>
    )
  }

  const handleResponseDomainSelection = (type, id) => {
    const path = url(routes.instruments.instrument.build.responseDomains.show, { instrument_id: instrumentId, responseDomainType: type, responseDomainId: id })
    history.push(path);
  }

  const responseDomainForm = () => {
    switch(responseDomainType) {
      case('ResponseDomainNumeric'):
          return <ResponseDomainNumericForm responseDomain={selectedResponseDomain} instrumentId={instrumentId} />
      case('ResponseDomainText'):
          return <ResponseDomainTextForm responseDomain={selectedResponseDomain} instrumentId={instrumentId} />
      case('ResponseDomainDatetime'):
          return <ResponseDomainDatetimeForm responseDomain={selectedResponseDomain} instrumentId={instrumentId} />
      default:
        return ''
    }
  }

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={instrumentId} instrumentId={instrumentId}>
        <Grid container spacing={3}>
          <Grid item xs={4}>
            <Paper className={classes.control}>
              <h2>Response Domains</h2>
              <CreateNewBuildObjectButtons instrumentId={instrumentId} objectTypes={['ResponseDomainText', 'ResponseDomainNumeric', 'ResponseDomainDatetime']} />
              <List dense={true}>
                {Object.values(responseDomains).map((responseDomain) => {
                  return <ResponseDomainItem label={responseDomain.label} type={responseDomain.type} id={responseDomain.id} />
                })}
              </List>
            </Paper>
          </Grid>
          <Grid item xs={8}>
            <Paper className={classes.side}>
              { responseDomainForm() }
            </Paper>
          </Grid>
        </Grid>
      </Dashboard>
    </div>
  );
}

export default InstrumentBuildResponseDomains;

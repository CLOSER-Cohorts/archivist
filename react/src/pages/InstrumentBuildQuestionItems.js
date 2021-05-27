import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { QuestionItems } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { QuestionItemForm } from '../components/QuestionItemForm'
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
import { Link } from 'react-router-dom';

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
  }
}));

const InstrumentBuildQuestionItems = (props) => {
  let history = useHistory();

  const dispatch = useDispatch()
  const classes = useStyles();
  const questionItemId = get(props, "match.params.questionItemId", null);

  const instrumentId = get(props, "match.params.instrument_id", "")
  const questionItems = useSelector(state => get(state.questionItems, instrumentId, {}));
  const selectedQuestion = get(questionItems, questionItemId, {used_by: []})

  useEffect(() => {
    dispatch(QuestionItems.all(instrumentId));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  const QuestionItem = (props) => {
    const {label, value, id} = props
    const classes = useStyles()

    return (
      <ListItem>
        <ListItemText
          className={classes.truncate} primary={label} onClick={()=>{handleQuestionSelection(id)}}/>
      </ListItem>
    )
  }

  const handleQuestionSelection = (id) => {
    const path = url(routes.instruments.instrument.build.questionItems.show, { instrument_id: instrumentId, questionItemId: id })
    history.push(path);
  }

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={instrumentId} instrumentId={instrumentId}>
        <Grid container spacing={3}>
          <Grid item xs={3}>
            <Paper className={classes.control}>
              <h2>Question Items <Link to={url(routes.instruments.instrument.build.questionGrids.all, { instrument_id: instrumentId })}>Question Grids</Link></h2>
              <CreateNewBuildObjectButtons instrumentId={instrumentId} objectTypes={['QuestionItem', 'QuestionGrid']} />
              <List dense={true}>
                {Object.values(questionItems).map((questionItem) => {
                  return <QuestionItem label={questionItem.label} id={questionItem.id} />
                })}
              </List>
            </Paper>
          </Grid>
          <Grid item xs={9}>
            {!isNil(selectedQuestion) && (
              <QuestionItemForm questionItem={selectedQuestion} instrumentId={instrumentId} />
            )}
          </Grid>
        </Grid>
      </Dashboard>
    </div>
  );
}

export default InstrumentBuildQuestionItems;

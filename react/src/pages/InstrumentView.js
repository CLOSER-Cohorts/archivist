import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Instrument, CcConditions, CcSequences, CcStatements, CcQuestions, QuestionItems, QuestionGrids, Variables, Topics } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { InstrumentHeading } from '../components/InstrumentHeading'
import { Loader } from '../components/Loader'
import { get, isEmpty, isNil } from "lodash";

import { makeStyles, withStyles } from '@material-ui/core/styles';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import Collapse from '@material-ui/core/Collapse';
import ExpandLess from '@material-ui/icons/ExpandLess';
import ExpandMore from '@material-ui/icons/ExpandMore';
import Chip from '@material-ui/core/Chip';
import BounceLoader from "react-spinners/BounceLoader";
import { Box, Grid, Typography } from '@material-ui/core'
import { ObjectColour } from '../support/ObjectColour'
import { HumanizeObjectType } from '../support/HumanizeObjectType'
import TextFieldsIcon from '@material-ui/icons/TextFields';
import CheckCircleOutlineIcon from '@material-ui/icons/CheckCircleOutline';
import TodayIcon from '@material-ui/icons/Today';
import Filter1Icon from '@material-ui/icons/Filter1';

const useStyles = makeStyles((theme) => ({
  root: {
    width: '100%'
  },
  control: {
    width: '100%',
    padding: theme.spacing(2),
  },
  nested: {
    paddingLeft: theme.spacing(4),
  }
}));

const ObjectFinder = (instrumentId, type, id) => {
  const sequences = useSelector(state => state.cc_sequences);
  const cc_sequences = get(sequences, instrumentId, {})
  const statements = useSelector(state => state.cc_statements);
  const cc_statements = get(statements, instrumentId, {})
  const conditions = useSelector(state => state.cc_conditions);
  const cc_conditions = get(conditions, instrumentId, {})
  const questions = useSelector(state => state.cc_questions);
  const cc_questions = get(questions, instrumentId, {})
  const allQuestionItems = useSelector(state => state.questionItems);
  const questionItems = get(allQuestionItems, instrumentId, {})
  const allQuestionGrids = useSelector(state => state.questionGrids);
  const questionGrids = get(allQuestionGrids, instrumentId, {})

  var item = {children: []}

  if(type === 'CcSequence'){
    item = get(cc_sequences, id.toString(), {})
  }

  if(type === 'CcStatement'){
    item = get(cc_statements, id.toString(), {})
  }

  if(type === 'CcCondition'){
    item = get(cc_conditions, id.toString(), {})
  }

  if(type === 'CcQuestion'){
    item = get(cc_questions, id.toString(), {})

    if(item.question_type === 'QuestionItem'){
      item.question = get(questionItems, item.question_id.toString(), {})
    }else if(item.question_type === 'QuestionGrid'){
      item.question = get(questionGrids, item.question_id.toString(), {})
    }
  }

  return item

}

const constructLabelClasses = makeStyles((theme) => ({
  CcCondition: {
    background: `#${ObjectColour('condition')}`,
    color: 'white'
  },
  CcStatement: {
    background: `#${ObjectColour('statement')}`,
    color: 'white'
  },
  CcQuestion: {
    background: `#${ObjectColour('question')}`,
    color: 'white'
  }
}));

const ConstructLabel = ({item, type}) => {
  const classes = constructLabelClasses();

  return (<Chip label={`${HumanizeObjectType(type)} : ${item.label}`} className={classes[type]}/>)
}

const QuestionItemListItem = (props) => {
  const {type, id, instrumentId} = props
  const item = ObjectFinder(instrumentId, type, id)

  if(isNil(item.question)){
    return ''
  }
  return (
    <Grid container spacing={3}>
      <Grid item xs={3}>
        <ConstructLabel item={item} type={type} />
      </Grid>

      <Grid item xs={9}>
        {item.question.literal}
        {(item.question.rds) && (
          <ResponseDomains rds={item.question.rds} />
        )}
      </Grid>
    </Grid>
  )
}

const responseDomainClasses = makeStyles((theme) => ({
  root: {
    listStyleType:'none'
  }
}));

const ResponseDomains = ({ rds }) => {
  const classes = responseDomainClasses();
  return rds.map((rd) => {
    switch (rd.type) {
      case 'ResponseDomainCode':
        return(<ul className={classes.root}><ResponseDomainCodes codes={rd.codes} /></ul>)
      case 'ResponseDomainText':
        return(<ul className={classes.root}><li><TextFieldsIcon /> {rd.label} ({`${(isNil(rd.maxlen)) ? 'no' : rd.maxlen} maximum length`})</li></ul>)
      case 'ResponseDomainNumeric':
        return(<ul className={classes.root}><li><Filter1Icon /> {rd.label} {rd.params} {rd.subtype}</li></ul>)
      case 'ResponseDomainDatetime':
        return(<ul className={classes.root}><li><TodayIcon /> {rd.label} {rd.params} {rd.subtype}</li></ul>)
      default:
        return '';
    }
  })
}

const ResponseDomainCodes = ({ codes }) => {
  return codes.map((code) => {
      return(<li><CheckCircleOutlineIcon /> <em>Value : {code.value} </em> = {code.label}</li>)
    })
}

const QuestionGridListItem = (props) => {

  return (
    <div>This is a Question Grid</div>
  )
}

const StatementListItem = (props) => {
  const {type, id, instrumentId} = props
  const item = ObjectFinder(instrumentId, type, id)

  return (
    <Grid container spacing={3}>
      <Grid item xs={3}>
        <ConstructLabel item={item} type={type} />
      </Grid>

      <Grid item xs={9}>
        {item.literal}
      </Grid>
    </Grid>
  )
}

const ConditionItem = (props) => {
  const {type, id, instrumentId, title} = props
  const classes = useStyles();
  const [open, setOpen] = React.useState(true);

  const handleClick = () => {
    setOpen(!open);
  };

  var item = ObjectFinder(instrumentId, type, id)

  return (
    <List
      component="nav"
      aria-labelledby="nested-list-subheader"
      className={classes.root}
    >
      <ListItem>
        <Grid container spacing={3}>
          <Grid item xs={3}>
            <ConstructLabel item={item} type={type} />
          </Grid>

          <Grid item xs={9}>
            <ListItemText primary={get(item, 'literal', title)} secondary={item.logic} />
          </Grid>
        </Grid>
        {open ? <ExpandLess onClick={handleClick}/> : <ExpandMore onClick={handleClick}/>}
      </ListItem>
      {!isEmpty(item.children) && (
        <Collapse in={open} timeout="auto" unmountOnExit>
          <List component="div" disablePadding>
            {item.children.map((child) => (
              <StyledListItem className={classes.nested}>
                {(function() {
                  switch (child.type) {
                    case 'CcSequence':
                      return <SequenceItem instrumentId={instrumentId} id={child.id} type={child.type} title={child.type} children={get(child,'children',[])} />;
                    case 'CcQuestion':
                      return <QuestionItemListItem instrumentId={instrumentId} id={child.id} type={child.type} />
                    case 'CcCondition':
                      return <ConditionItem instrumentId={instrumentId} id={child.id} type={child.type} />
                    default:
                      return null;
                  }
                })()}
              </StyledListItem>
            ))}
          </List>
        </Collapse>
      )}
    </List>
  );
}

const SequenceItem = (props) => {
  const {type, id, instrumentId} = props
  var {title} = props;
  const classes = useStyles();
  const [open, setOpen] = React.useState(true);

  const handleClick = () => {
    setOpen(!open);
  };

  var item = ObjectFinder(instrumentId, props.type, props.id)

  title = get(item, 'label', props.title)

  return (
    <List
      className={classes.sequence}
    >
      <ListItem className={classes.sequence}>
          <Typography variant="h5" component="h5">{title}</Typography>
          {open ? <ExpandLess onClick={handleClick}  /> : <ExpandMore onClick={handleClick}  />}
      </ListItem >
      {!isEmpty(item.children) && (
        <Collapse in={open} timeout="auto" unmountOnExit>
          <List component="div" disablePadding>
            {item.children.map((child) => (
                (function() {
                  switch (child.type) {
                    case 'CcSequence':
                      return (
                          <StyledListItem className={classes.nested}>
                            <SequenceItem instrumentId={instrumentId} id={child.id} type={child.type} title={child.type} children={get(child,'children',[])} />
                          </StyledListItem>)
                    case 'CcQuestion':
                      return (
                          <StyledListItem className={classes.nested}>
                            <QuestionItemListItem instrumentId={instrumentId} id={child.id} type={child.type} />
                          </StyledListItem>)
                    case 'CcStatement':
                      return (
                          <StyledListItem className={classes.nested}>
                            <StatementListItem instrumentId={instrumentId} id={child.id} type={child.type} />
                          </StyledListItem>)
                    case 'CcCondition':
                      return (
                          <StyledListItem className={classes.nested}>
                            <ConditionItem instrumentId={instrumentId} id={child.id} type={child.type} children={get(child,'children',[])} />
                          </StyledListItem>)
                    default:
                      return null;
                  }
                })()
            ))}
          </List>
        </Collapse>
      )}
    </List>
  );
}

const InstrumentView = (props) => {

  const dispatch = useDispatch()
  const instrumentId = get(props, "match.params.instrument_id", "")
  const instrument = useSelector(state => get(state.instruments, instrumentId));
  const sequences = useSelector(state => state.cc_sequences);
  const cc_sequences = get(sequences, instrumentId, {})
  const [dataLoaded, setDataLoaded] = useState(false);

  useEffect(() => {
    Promise.all([
      dispatch(Instrument.show(instrumentId)),
      dispatch(CcSequences.all(instrumentId)),
      dispatch(CcStatements.all(instrumentId)),
      dispatch(CcConditions.all(instrumentId)),
      dispatch(CcQuestions.all(instrumentId)),
      dispatch(QuestionItems.all(instrumentId)),
      dispatch(QuestionGrids.all(instrumentId)),
      dispatch(Variables.all(instrumentId)),
      dispatch(Topics.all())
    ]).then(() => {
      setDataLoaded(true)
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  const sequence = (isEmpty(cc_sequences)) ? undefined : Object.values(cc_sequences).find(element => element.top == true)

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'View'} instrumentId={instrumentId}>
      <InstrumentHeading instrument={instrument} mode={'view'} />
        {!dataLoaded
        ? <Loader />
        : <SequenceItem instrumentId={instrumentId} type={'CcSequence'} id={sequence.children[0].id} title={sequence.children[0].label} children={sequence.children[0].children}/>
      }
      </Dashboard>
    </div>
  );
}

const StyledChip = withStyles({
  root: {
    background: 'linear-gradient(45deg, #00adee 30%, #00adee 90%)',
    borderRadius: 3,
    border: 0,
    color: 'white',
    height: 30,
    'margin-right': 5,
    padding: '0 30px',
    boxShadow: '0 3px 5px 2px #00adee',
  },
  label: {
    textTransform: '',
  },
})(Chip);

const StyledListItem = withStyles({
  root: {
    borderRadius: 5,
    border: '2px solid #00adee',
    backgroundColor: 'rgba(0,173,238, 0.1)',
    'margin-bottom': '10px'
  },
  label: {
    textTransform: '',
  },
})(ListItem);

export default InstrumentView;

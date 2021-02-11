import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Instrument, CcConditions, CcSequences, CcStatements, CcQuestions, QuestionItems, QuestionGrids, Variables, Topics } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { get, isEmpty, isNil } from "lodash";
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/Paper';

import { makeStyles } from '@material-ui/core/styles';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import Collapse from '@material-ui/core/Collapse';
import DoneIcon from '@material-ui/icons/Done';
import ExpandLess from '@material-ui/icons/ExpandLess';
import ExpandMore from '@material-ui/icons/ExpandMore';
import Chip from '@material-ui/core/Chip';
import Autocomplete from '@material-ui/lab/Autocomplete';
import TextField from '@material-ui/core/TextField';
import FormControl from '@material-ui/core/FormControl';
import InputLabel from '@material-ui/core/InputLabel';
import Select from '@material-ui/core/Select';
import { Alert, AlertTitle } from '@material-ui/lab';
import BounceLoader from "react-spinners/BounceLoader";
import SyncLoader from "react-spinners/SyncLoader";
import { Box } from '@material-ui/core'

const useStyles = makeStyles((theme) => ({
  root: {
    width: '100%',
    backgroundColor: theme.palette.background.paper
  },
  control: {
    width: '100%',
    padding: theme.spacing(2),
  },
  nested: {
    paddingLeft: theme.spacing(4),
  },
}));

const ObjectStatus = (id, type) => {
  const statuses = useSelector(state => state.statuses);
  const key = type + ':' + id
  return get(statuses, key, {})
}

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

const QuestionItemListItem = (props) => {
  const {type, id, instrumentId} = props
  const item = ObjectFinder(instrumentId, type, id)
  const classes = useStyles();
  console.log(item)
  return (
    <div>
      {item.question.literal}
      {(item.question.rds) && (
        <ResponseDomains rds={item.question.rds} />
      )}
    </div>
  )
}

const ResponseDomains = ({ rds }) => {

  return rds.map((rd) => {
    console.log(rd)
    switch (rd.type) {
      case 'ResponseDomainCode':
        return(<ul><ResponseDomainCodes codes={rd.codes} /></ul>)
      case 'ResponseDomainText':
        return(<ul><li>{rd.label}</li></ul>)
      case 'ResponseDomainNumeric':
        return(<ul><li>{rd.label} {rd.params} {rd.subtype}</li></ul>)
      case 'ResponseDomainDatetime':
        return(<ul><li>{rd.label} {rd.params} {rd.subtype}</li></ul>)
      default:
        console.log(rd)
        return '';
    }
  })
}

const ResponseDomainCodes = ({ codes }) => {
  return codes.map((code) => {
      return(<li>{code.label}</li>)
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
  const classes = useStyles();

  return (
    <div>{item.literal}</div>
  )
}

const ConditionItem = (props) => {
  const { instrumentId } = props;
  var {title} = props;
  const classes = useStyles();
  const [open, setOpen] = React.useState(true);

  const handleClick = () => {
    setOpen(!open);
  };

  var item = ObjectFinder(instrumentId, props.type, props.id)

  title = get(item, 'literal', props.title)

  return (
    <List
      component="nav"
      aria-labelledby="nested-list-subheader"
      className={classes.root}
    >
      <ListItem button onClick={handleClick}>
        <ListItemText primary={title} />
          {open ? <ExpandLess /> : <ExpandMore />}
      </ListItem>
      {!isEmpty(item.children) && (
        <Collapse in={open} timeout="auto" unmountOnExit>
          <List component="div" disablePadding>
            {item.children.map((child) => (
              <ListItem button className={classes.nested}>
                {(function() {
                  switch (child.type) {
                    case 'CcSequence':
                      return <SequenceItem instrumentId={instrumentId} id={child.id} type={child.type} title={child.type} children={get(child,'children',[])} />;
                    case 'CcQuestion':
                      return <QuestionItemListItem instrumentId={instrumentId} id={child.id} type={child.type} />
                    case 'CcCondition':
                      return <ConditionItem instrumentId={instrumentId} id={child.id} type={child.type} />
                    default:
                      console.log(child)
                      return null;
                  }
                })()}
              </ListItem>
            ))}
          </List>
        </Collapse>
      )}
    </List>
  );
}

const SequenceItem = (props) => {
  const { instrumentId } = props;
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
      component="nav"
      aria-labelledby="nested-list-subheader"
      className={classes.root}
    >
      <ListItem button onClick={handleClick}>
        <ListItemText primary={title} />
          {open ? <ExpandLess /> : <ExpandMore />}
      </ListItem>
      {!isEmpty(item.children) && (
        <Collapse in={open} timeout="auto" unmountOnExit>
          <List component="div" disablePadding>
            {item.children.map((child) => (
                (function() {
                  switch (child.type) {
                    case 'CcSequence':
                      return (
                          <ListItem button className={classes.nested}>
                            <SequenceItem instrumentId={instrumentId} id={child.id} type={child.type} title={child.type} children={get(child,'children',[])} />
                          </ListItem>)
                    case 'CcQuestion':
                      return (
                          <ListItem button className={classes.nested}>
                            <QuestionItemListItem instrumentId={instrumentId} id={child.id} type={child.type} />
                          </ListItem>)
                    case 'CcStatement':
                      return (
                          <ListItem button className={classes.nested}>
                            <StatementListItem instrumentId={instrumentId} id={child.id} type={child.type} />
                          </ListItem>)
                    case 'CcCondition':
                      return (
                          <ListItem button className={classes.nested}>
                            <ConditionItem instrumentId={instrumentId} id={child.id} type={child.type} children={get(child,'children',[])} />
                          </ListItem>)
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

  useEffect(() => {
    dispatch(Instrument.show(instrumentId));
    dispatch(CcSequences.all(instrumentId));
    dispatch(CcStatements.all(instrumentId));
    dispatch(CcConditions.all(instrumentId));
    dispatch(CcQuestions.all(instrumentId));
    dispatch(QuestionItems.all(instrumentId));
    dispatch(QuestionGrids.all(instrumentId));
    dispatch(Variables.all(instrumentId));
    dispatch(Topics.all());
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  const sequence = (isEmpty(cc_sequences)) ? undefined : Object.values(cc_sequences).find(element => element.top == true)

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Maps'} instrumentId={instrumentId}>
        <h1>{get(instrument, 'label')}</h1>
      {isNil(sequence)
        ? <Box m="auto"><BounceLoader color={'#009de6'}/></Box>
        : <SequenceItem instrumentId={instrumentId} type={'CcSequence'} id={sequence.children[0].id} title={sequence.children[0].label} children={sequence.children[0].children}/>
      }
      </Dashboard>
    </div>
  );
}

export default InstrumentView;

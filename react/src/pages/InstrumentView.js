import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { useParams } from 'react-router-dom';
import { Instrument, CcConditions, CcLoops, CcSequences, CcStatements, CcQuestions, QuestionItems, QuestionGrids, Variables, Topics } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { InstrumentHeading } from '../components/InstrumentHeading'
import { Loader } from '../components/Loader'
import { get, isEmpty, isNil, times } from "lodash";

import { makeStyles, withStyles } from '@material-ui/core/styles';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import Collapse from '@material-ui/core/Collapse';
import ExpandLess from '@material-ui/icons/ExpandLess';
import ExpandMore from '@material-ui/icons/ExpandMore';
import Chip from '@material-ui/core/Chip';
import Divider from '@material-ui/core/Divider';
import { Grid, Typography } from '@material-ui/core'
import { ObjectColour } from '../support/ObjectColour'
import TextFieldsIcon from '@material-ui/icons/TextFields';
import CheckCircleOutlineIcon from '@material-ui/icons/CheckCircleOutline';
import TodayIcon from '@material-ui/icons/Today';
import Filter1Icon from '@material-ui/icons/Filter1';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Tooltip from '@material-ui/core/Tooltip';

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
  },
  rosterLabel: {
    backgroundColor: 'lightgray',
    height: 25
  },
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
  const questionGrids = get(allQuestionGrids, instrumentId, {});
  const loops = useSelector(state => state.cc_loops);
  const cc_loops = get(loops, instrumentId, {})

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

  if(type === 'CcLoop'){
    item = get(cc_loops, id.toString(), {})
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

  return (<Chip label={`${item.label}`} className={classes[type]}/>)
}

const questionStyles = makeStyles((theme) => ({
  container: {
    padding: theme.spacing(2),
  },
  details: {
    paddingBottom: theme.spacing(2),
    paddingLeft: theme.spacing(2),
    paddingRight: theme.spacing(2),
    borderRadius: theme.shape.borderRadius,
    boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)',
  },    
  secondaryDetails: {
  },
  label: {
    fontWeight: 'bold',
    textAlign: 'left',
    marginBottom: theme.spacing(1),
  },
  questionLiteral: {
    marginBottom: theme.spacing(2),
    color: '#333',
  },
  sectionHeading: {
    fontWeight: 700,
    marginTop: theme.spacing(2),
    marginBottom: theme.spacing(1),
    fontSize: '1rem',
  },
  sectionContent: {
    fontSize: '0.9rem',
    marginBottom: theme.spacing(1),
  },
  table: {
    border: '1px solid #ccc',
    borderCollapse: 'collapse',
  },
  tableCell: {
    border: '1px solid #ccc',
    padding: theme.spacing(1),
  },
  tableRow: {
    '&:nth-of-type(odd)': {
      backgroundColor: '#f4f4f4',
    },
  },  
}));

const QuestionItemListItem = (props) => {
  const { item } = props;
  const classes = questionStyles();

  if (isNil(item) || isNil(item.question)) {
    return '';
  }

  return (
    <Grid container spacing={2} alignItems="flex-start" className={classes.container}>
      <Grid item xs={2} sm={2}>
        <Typography className={classes.label}>
          <ConstructLabel item={item} type="CcQuestion" />
        </Typography>
      </Grid>

      <Grid item xs={10} sm={10}>
        <div className={classes.details}>         
          {!isEmpty(item.interviewee) && (
              <>
                <Typography className={classes.sectionHeading}>Interviewee</Typography>
                <Typography className={classes.sectionContent}>
                  {item.interviewee}
                </Typography>
              </>
            )}                      
          <Typography className={classes.sectionHeading}>Question Text</Typography>
          <Typography className={classes.questionLiteral}>
            {item.question.literal}
          </Typography>

          <div className={classes.secondaryDetails}>   
            {!isEmpty(item.question.instruction) && (
              <>
                <Typography className={classes.sectionHeading}>Instruction</Typography>
                <Typography className={classes.sectionContent}>
                  {item.question.instruction}
                </Typography>
              </>
            )}
            {item.question.rds && (
              <>
                <Typography className={classes.sectionHeading}>Response Domains</Typography>
                <Typography className={classes.sectionContent}>
                  <ResponseDomains rds={item.question.rds} />
                </Typography>
              </>
            )}
            {!isEmpty(item.variables) && (
              <>
                <Typography className={classes.sectionHeading}>Variables</Typography>
                <Typography className={classes.sectionContent}>
                  <VariableItems variables={item.variables} />
                </Typography>
              </>
            )}
          </div>
        </div>
      </Grid>
    </Grid>
  );
};

const QuestionGridListItem = (props) => {
  const { item } = props;
  const classes = questionStyles();

  if (isNil(item) || isNil(item.question)) {
    return '';
  }

  const rows = times(item.question.roster_rows, String);
  const questionRows = get(item.question, 'rows', []);

  return (
    <Grid container spacing={2} alignItems="flex-start" className={classes.container}>
      <Grid item xs={2} sm={2}>
        <Typography className={classes.label}>
          <ConstructLabel item={item} type={'CcQuestion'} />
        </Typography>
      </Grid>

      <Grid item xs={10} sm={10}>
        <div className={classes.details}>
          <Typography className={classes.questionLiteral}>
            {item.question.literal}
          </Typography>
            <Table size="small" className={classes.table}>
            <TableHead>
              <TableRow>
                <TableCell className={classes.tableCell}>
                  <Typography className={classes.sectionHeading}>
                    {item.question.pretty_corner_label}
                  </Typography>
                </TableCell>
                {item.question.cols.map((header) => (
                  <TableCell key={header.label} className={classes.tableCell}>
                    <Typography className={classes.sectionHeading}>
                      {header.label}
                    </Typography>
                    <ResponseDomains rds={[header.rd]} />
                  </TableCell>
                ))}
              </TableRow>
            </TableHead>
            <TableBody>
              {questionRows.map((row) => (
                <TableRow key={row.label} className={classes.tableRow}>
                  <TableCell className={classes.tableCell}>
                    <Typography className={classes.sectionContent}>
                      {row.label}
                    </Typography>
                  </TableCell>
                </TableRow>
              ))}
              {rows.map((row, i) => (
                <TableRow key={i} className={classes.tableRow}>
                  <TableCell className={classes.tableCell}>
                    <Typography className={classes.sectionContent}>
                      {i === 0 ? item.question.roster_label : ''}
                    </Typography>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>       

          <div className={classes.secondaryDetails}>
            {!isEmpty(item.question.instruction) && (
              <>
                <Typography className={classes.sectionHeading}>Instruction</Typography>
                <Typography className={classes.sectionContent}>
                  {item.question.instruction}
                </Typography>
              </>
            )}

            {!isEmpty(item.variables) && (
              <>
                <Typography className={classes.sectionHeading}>Variables</Typography>
                <Typography className={classes.sectionContent}>
                  <VariableItems variables={item.variables} />
                </Typography>
              </>
            )}
          </div>
        </div>
      </Grid>
    </Grid>
  );
};

const QuestionListItem = (props) => {
  const {type, id, instrumentId} = props
  const item = ObjectFinder(instrumentId, type, id)

  if(isNil(item.question)){
    return ''
  }

  if(item.question_type === 'QuestionGrid'){
    return <QuestionGridListItem item={item} />
  }else{
    return <QuestionItemListItem item={item} />
  }
}

const responseDomainClasses = makeStyles((theme) => ({
  root: {
    listStyleType:'none',
  },
  secondary: {
  }
}));

const VariableItems = ({ variables }) => {
  if(isEmpty(variables)){
    return ''
  }else{
    return (
        <>
          <ul>
            { variables.map((variable) => {
              return (
                <li>
                  <Tooltip arrow title={variable.label}><span>{variable.name}</span></Tooltip>
                </li>
              )
              })
            }
          </ul>
        </>
    )
  }
}

const ResponseDomains = ({ rds }) => {
  const classes = responseDomainClasses();

  return rds.filter((rd)  => { return !isNil(rd) }).map((rd) => {
    switch (rd.type) {
      case 'ResponseDomainCode':
        return(<><ul className={classes.root}><ResponseDomainCodes codes={rd.codes} /></ul><span className={classes.secondary}>Min : <strong>{ rd.min_responses }</strong> Max : <strong>{ rd.max_responses }</strong></span></>)
      case 'ResponseDomainText':
        return(<ul className={classes.root}><li><TextFieldsIcon /> {rd.label} ({`max: ${(isNil(rd.maxlen)) ? 'no' : rd.maxlen}`})</li></ul>)
      case 'ResponseDomainNumeric':
        return(<ul className={classes.root}><li><Filter1Icon /> {rd.label} {rd.params} {rd.subtype}</li></ul>)
      case 'ResponseDomainDatetime':
        return(<ul className={classes.root}><li><TodayIcon /> {rd.label} {rd.params}</li></ul>)
      default:
        return '';
    }
  })
}

const ResponseDomainCodes = ({ codes }) => {
  return codes.map((code) => {
      return(<li><CheckCircleOutlineIcon /> <em>{code.value} </em> = {code.label}</li>)
    })
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

const ConditionChildren = (props) => {
  const {children, instrumentId, title} = props
  const classes = useStyles();
  const [open, setOpen] = React.useState(true);

  const handleClick = () => {
    setOpen(!open);
  };

  return (
    <List
      component="nav"
      aria-labelledby="nested-list-subheader"
      className={classes.root}
    >
      <ListItem>
        <Grid container spacing={3}>
          <Grid item xs={12}>
            <ListItemText primary={title} />
          </Grid>
        </Grid>
        {open ? <ExpandLess onClick={handleClick}/> : <ExpandMore onClick={handleClick}/>}
      </ListItem>
      {!isEmpty(children) && (
        <Collapse in={open} timeout="auto" unmountOnExit>
          <List component="div" disablePadding>
            {children.map((child) => (
              <StyledListItem className={classes.nested}>
                {(function() {
                  switch (child.type) {
                    case 'CcSequence':
                      return <SequenceItem instrumentId={instrumentId} id={child.id} type={child.type} title={child.type} children={get(child,'children',[])} />;
                    case 'CcQuestion':
                      return <QuestionListItem instrumentId={instrumentId} id={child.id} type={child.type} />
                    case 'CcCondition':
                      return <ConditionItem instrumentId={instrumentId} id={child.id} type={child.type} />
                    case 'CcStatement':
                      return <StatementListItem instrumentId={instrumentId} id={child.id} type={child.type} />
                    case 'CcLoop':
                      return <LoopItem instrumentId={instrumentId} id={child.id} type={child.type} />
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
            <ListItemText primary={get(item, 'literal', title)} secondary={(item.logic && item.logic.match(/^ *$/) == null) ? item.logic : '[]'} />
          </Grid>
        </Grid>
        {open ? <ExpandLess onClick={handleClick}/> : <ExpandMore onClick={handleClick}/>}
      </ListItem>
      <ConditionChildren instrumentId={instrumentId} title={'True'} children={item.children} />
      <ConditionChildren instrumentId={instrumentId} title={'Else'} children={item.fchildren} />
    </List>
  );
}

const LoopItem = (props) => {
  const {type, id, instrumentId, title} = props
  const classes = useStyles();
  const [open, setOpen] = React.useState(true);

  const handleClick = () => {
    setOpen(!open);
  };

  var item = ObjectFinder(instrumentId, type, id)

  var loop_description = `${item.loop_var} from ${item.start_val} while`

  if(item.end_val){
    loop_description += ` ${item.loop_var} <= ${item.end_val}`
  }

  if (item.loop_while) {
    loop_description += ` ${(item.end_val) ? '&& ' : ''}${item.loop_while}`
  }

  if (isNil(item.end_val) && isNil(item.loop_while)) {
    loop_description += ` []`
  }

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
            <Typography variant="h6" component="h6">{loop_description}</Typography>
          </Grid>
        </Grid>
        {open ? <ExpandLess onClick={handleClick}/> : <ExpandMore onClick={handleClick}/>}
      </ListItem>
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
                            <QuestionListItem instrumentId={instrumentId} id={child.id} type={child.type} />
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
                    case 'CcLoop':
                      return (
                          <StyledListItem className={classes.nested}>
                            <LoopItem instrumentId={instrumentId} id={child.id} type={child.type} />
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
                            <QuestionListItem instrumentId={instrumentId} id={child.id} type={child.type} />
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
                    case 'CcLoop':
                      return (
                          <StyledListItem className={classes.nested}>
                            <LoopItem instrumentId={instrumentId} id={child.id} type={child.type} children={get(child,'children',[])} />
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
  const { instrument_id: instrumentId } = useParams();
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
      dispatch(CcLoops.all(instrumentId)),
      dispatch(CcQuestions.all(instrumentId)),
      dispatch(QuestionItems.all(instrumentId)),
      dispatch(QuestionGrids.all(instrumentId)),
      dispatch(Variables.all(instrumentId)),
      dispatch(Topics.all())
    ]).then(() => {
      setDataLoaded(true)
    });
    
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

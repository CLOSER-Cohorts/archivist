import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Instrument, CcConditions, CcLoops, CcSequences, CcStatements, CcQuestions, QuestionItems, QuestionGrids, Variables, Topics } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { get, isEmpty, isNil, uniq } from "lodash";
import { InstrumentHeading } from '../components/InstrumentHeading'
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
import { Loader } from '../components/Loader'
import SyncLoader from "react-spinners/SyncLoader";
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import DescriptionIcon from '@material-ui/icons/Description';

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

  if (type === 'CcLoop') {
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

const SequenceTopicsFinder = (props) => {
  const dispatch = useDispatch()
  const { instrumentId, sequence } = props
  const questions = useSelector(state => state.cc_questions);
  const cc_questions = get(questions, instrumentId, {})

  var child_questions = sequence.children.filter((child) => { return child.type == 'CcQuestion' }).map((child) => { return get(cc_questions, child.id) })
  var topicIds = uniq(child_questions.map((question) => { return get(question, 'topic') }).filter((t) => { return t != null }).map((t) => { return t.id }))
  const resolvedTopicIds = uniq(child_questions.map((question) => { return get(question, 'resolved_topic') }).filter((t) => { return t != null }).map((t) => { return t.id }))
  topicIds = [topicIds, resolvedTopicIds].flat()

  const handleChange = (event, value, reason) => {
    child_questions.map((cc_question)=>{
      dispatch(CcQuestions.topic.set(instrumentId, cc_question.id, (reason === 'clear') ? null : value.id));
    })
  }

  if (new Set(topicIds).size > 1 || child_questions.length < 1){
    return ''
  }else{
    return (
      <TopicList topicId={get(topicIds, 0)} instrumentId={instrumentId} handleChange={handleChange} />
    )
  }
}

const StatementListItem = (props) => {
  const { type, id, instrumentId } = props
  const item = ObjectFinder(instrumentId, type, id)

  return (
    <ListItem>
      <ListItemText primary={item.literal} />
    </ListItem>
  )
}


const QuestionListItem = (props) => {
  const { type, id, instrumentId } = props
  const item = ObjectFinder(instrumentId, type, id)

  if (isNil(item.question)) {
    return ''
  }

  if (item.question_type === 'QuestionGrid') {
    return <QuestionGridListItem item={item} instrumentId={instrumentId} />
  } else {
    return <QuestionItemListItem item={item} instrumentId={instrumentId} />
  }
}

const QuestionItemListItem = (props) => {
  const {item, instrumentId} = props
  const classes = useStyles();

  const title = (isEmpty(item.question)) ? item.label : item.question.literal

  const topic = get(item, 'topic', {id: null})
  const topicId = get(topic, 'id', null)

  const variableTopic = get(item, 'variable_topic', {id: null})

  const status = ObjectStatus(item.id, 'CcQuestion')

  var errorMessage = null;

  if(status.error){
    errorMessage = status.errorMessage
  }else if(item.errors){
    errorMessage = item.errors
  }

  return (
      <ListItem>
      <Paper className={classes.control}>
      <Grid container spacing={3}>
          { !isEmpty(errorMessage) && (
            <div className={classes.root}>
              <Alert severity="error">
                <AlertTitle>Error</AlertTitle>
                {errorMessage}
              </Alert>
            </div>
          )}
          <Grid item xs={12}>
            <Chip label={item.label} color="primary"></Chip>
            {!isEmpty(status) && !isNil(status.saving) && (
              <Chip label="Saving" color="secondary">              <SyncLoader /></Chip>
            )}
            {!isEmpty(status) && !isNil(status.saved) && (
              <Chip label="Saved" color="success" deleteIcon={<DoneIcon />}></Chip>
            )}
            <ListItemText primary={title} />
          </Grid>
          <Grid item xs={6}>
            <VariableList variables={item.variables} instrumentId={instrumentId} ccQuestionId={item.id} topicId={topicId || get(variableTopic, 'id', null)} />
          </Grid>
          <Grid item xs={6}>
            <TopicList topicId={topicId} instrumentId={instrumentId} ccQuestionId={item.id} />
            {(isNil(get(topic, 'id')) && !isNil(variableTopic)) && (!isNil(get(variableTopic, 'name'))) && (
              <em>Resolved topic from variables - {get(variableTopic, 'name')}</em>
            )}
          </Grid>
        </Grid>
      </Paper>
      </ListItem>
  )
}

const QuestionGridListItem = (props) => {
  const { item, instrumentId } = props
  const classes = useStyles();

  const title = (isEmpty(item.question)) ? item.label : item.question.literal

  const topic = get(item, 'topic', { id: null })
  const topicId = get(topic, 'id', null)

  const variableTopic = get(item, 'variable_topic', { id: null })

  const status = ObjectStatus(item.id, 'CcQuestion')

  var errorMessage = null;

  if (status.error) {
    errorMessage = status.errorMessage
  } else if (item.errors) {
    errorMessage = item.errors
  }

  return (
    <ListItem>
      <Paper className={classes.control}>
        <Grid container spacing={3}>
          {!isEmpty(errorMessage) && (
            <div className={classes.root}>
              <Alert severity="error">
                <AlertTitle>Error</AlertTitle>
                {errorMessage}
              </Alert>
            </div>
          )}
          <Grid item xs={12}>
            <Chip label={item.label} color="primary"></Chip>
            {!isEmpty(status) && !isNil(status.saving) && (
              <Chip label="Saving" color="secondary">              <SyncLoader /></Chip>
            )}
            {!isEmpty(status) && !isNil(status.saved) && (
              <Chip label="Saved" color="success" deleteIcon={<DoneIcon />}></Chip>
            )}
            <ListItemText primary={title} />
          </Grid>
          <Grid item xs={12}>
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell><strong>{item.question.pretty_corner_label}</strong></TableCell>
                  {item.question.cols.map((header) => (
                    <TableCell><strong>{header.label}</strong></TableCell>
                  ))}
                </TableRow>
              </TableHead>
              <TableBody>
                {item.question.rows && item.question.rows.map((row, y) => (
                  <TableRow key={row.label}>
                    <TableCell><strong>{row.label}</strong></TableCell>
                    {item.question.cols.map((header, x) => (
                      <TableCell>
                        <VariableList variables={item.variables.filter((variable) => { return variable.y == y + 1 && variable.x == x + 1 })} instrumentId={instrumentId} ccQuestionId={item.id} x={x + 1} y={y + 1} topicId={topicId || get(variableTopic, 'id', null)} />
                      </TableCell>
                    ))}
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </Grid>
          <Grid item xs={6}>
            <VariableList variables={item.variables.filter((variable) => { return (variable.y == 0 && variable.x == 0) || (variable.y == undefined && variable.x == undefined) })} instrumentId={instrumentId} ccQuestionId={item.id} x={0} y={0} topicId={topicId || get(variableTopic, 'id', null)} label={'Map whole grid to variables'} />
          </Grid>
          <Grid item xs={6}>
            <TopicList topicId={topicId} instrumentId={instrumentId} ccQuestionId={item.id} />
            {(isNil(get(topic, 'id')) && !isNil(variableTopic)) && (!isNil(get(variableTopic, 'name'))) && (
              <em>Resolved topic from variables - {get(variableTopic, 'name')}</em>
            )}
          </Grid>
        </Grid>
      </Paper>
    </ListItem>
  )
}

const TopicList = (props) => {
  const dispatch = useDispatch()
  const {topicId, instrumentId, ccQuestionId=undefined} = props
  const { handleChange=(event, value, reason) => {
    dispatch(CcQuestions.topic.set(instrumentId, ccQuestionId, (reason === 'clear') ? null : value.id));
  }} = props

  const topics = useSelector(state => state.topics);
  const topicOptions = [{id: null, name: '', level: 1}].concat(Object.values(get(topics,'flattened', {})));
  const classes = makeStyles((theme) => ({
    root: {
      flexGrow: 1,
    },
    paper: {
      padding: theme.spacing(2),
      textAlign: 'center',
      color: theme.palette.text.secondary,
    },
  }));

  if (isEmpty(topics) || isEmpty(topics.flattened)){
    return 'Fetching topics'
  }else if(isNil(topicId)){
    return (
          <div>
            <span></span>
            <Autocomplete
              onChange={handleChange}
              options={topicOptions}
              renderInput={params => (
                <TextField {...params} label="Topic" variant="outlined" />
              )}
              getOptionLabel={option => (option.level === 1) ? option.name : '--' + option.name}
            />
          </div>
    )
  }else{
    return (
          <div>
            <Autocomplete
              onChange={handleChange}
              options={topicOptions}
              renderInput={params => (
                <TextField {...params} label="Topic" variant="outlined" />
              )}
              value={Object.values(topics.flattened).find(topic => { return topic.id == topicId })}
              getOptionLabel={option => (option.level === 1) ? option.name : '--' + option.name}
            />
          </div>
    )
  }
}

const VariableList = (props) => {
  const {variables, instrumentId, ccQuestionId, x, y, topicId, label='Variables'} = props

  const dispatch = useDispatch()

  const allVariables = useSelector(state => state.variables);
  var variableOptions = Object.values(get(allVariables, instrumentId, {}))
  if(!isEmpty(topicId)) {
    variableOptions = variableOptions.filter(opt => {
      return (
        get(opt.topic, 'id') == topicId ||
        get(opt.resolved_topic, 'id') == topicId ||
        (get(opt.topic, 'id') === 0 && get(opt.resolved_topic, 'id') === 0) || (opt.topic === null && opt.resolved_topic === null)
      )
    })
  }

  const handleAddVariable = (newVariables) => {
    dispatch(CcQuestions.variables.add(instrumentId, ccQuestionId, newVariables, x, y));
  }

  const handleRemoveVariable = (oldVariables) => {
    dispatch(CcQuestions.variables.remove(instrumentId, ccQuestionId, oldVariables, x, y));
  }

  var difference = []

  const handleChange = (event, value, reason) => {
    switch (reason) {
      case 'select-option':
        difference = value.filter(x => !variables.includes(x));
        if(!isEmpty(difference)){
          return handleAddVariable(difference.map((variable) => { return variable.name }).join(','))
        };
        break;
      case 'remove-option':
        difference = variables.filter(x => !value.includes(x));
        if(!isEmpty(difference)){
          return handleRemoveVariable(difference.map((variable) => { return variable.id }).join(','))
        };
        break;
      default:
        return null;
    }
  }

  if(isEmpty(variables)){
    return (
      <div>
         <Autocomplete
          multiple
          id="tags-outlined"
          options={variableOptions}
          getOptionLabel={(option) => option.name}
          onChange={handleChange}
          value={[]}
          filterSelectedOptions
          renderInput={(params) => (
            <TextField
              {...params}
              variant="outlined"
              label={label}
              placeholder="Add variable"
            />
          )}
        />
      </div>
    )
  }else{
    return (
      <div>
         <Autocomplete
          multiple
          id="tags-outlined"
          options={Object.values(variableOptions)}
          getOptionLabel={(option) => option.name}
          onChange={handleChange}
          value={variables}
          getOptionSelected= {(option, value) => (
            option.id === value.id
          )}
          filterSelectedOptions
          renderInput={(params) => (
            <TextField
              {...params}
              variant="outlined"
              label={label}
              placeholder="Add variable"
            />
          )}
        />
      </div>
    )
  }
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
      <Collapse in={open} timeout="auto" unmountOnExit>
        <ListItem>
          <ListItemText primary={'True'} />
        </ListItem>
        {!isEmpty(item.children) && (
          <List component="div" disablePadding>
            {item.children.map((child) => (
              <ListItem button className={classes.nested}>
                {(function() {
                  switch (child.type) {
                    case 'CcSequence':
                      return <SequenceItem instrumentId={instrumentId} id={child.id} type={child.type} title={child.type} children={get(child,'children',[])} />;
                    case 'CcQuestion':
                      return <QuestionListItem instrumentId={instrumentId} id={child.id} type={child.type} />
                    case 'CcCondition':
                      return <ConditionItem instrumentId={instrumentId} id={child.id} type={child.type} />
                    case 'CcLoop':
                      return <LoopItem instrumentId={instrumentId} id={child.id} type={child.type} />
                    case 'CcStatement':
                      return <StatementListItem instrumentId={instrumentId} id={child.id} type={child.type} />
                    default:
                      return null;
                  }
                })()}
              </ListItem>
            ))}
          </List>
        )}
        <ListItem>
          <ListItemText primary={'False'} />
        </ListItem>
        {!isEmpty(item.fchildren) && (
          <List component="div" disablePadding>
            {item.fchildren.map((child) => (
              <ListItem button className={classes.nested}>
                {(function () {
                  switch (child.type) {
                    case 'CcSequence':
                      return <SequenceItem instrumentId={instrumentId} id={child.id} type={child.type} title={child.type} children={get(child, 'children', [])} />;
                    case 'CcQuestion':
                      return <QuestionListItem instrumentId={instrumentId} id={child.id} type={child.type} />
                    case 'CcCondition':
                      return <ConditionItem instrumentId={instrumentId} id={child.id} type={child.type} />
                    case 'CcLoop':
                      return <LoopItem instrumentId={instrumentId} id={child.id} type={child.type} />
                    case 'CcStatement':
                      return <StatementListItem instrumentId={instrumentId} id={child.id} type={child.type} />
                    default:
                      return null;
                  }
                })()}
              </ListItem>
            ))}
          </List>
        )}
      </Collapse>
    </List>
  );
}

const LoopItem = (props) => {
  const { type, id, instrumentId, title } = props
  const classes = useStyles();
  const [open, setOpen] = React.useState(true);

  const handleClick = () => {
    setOpen(!open);
  };

  var item = ObjectFinder(instrumentId, type, id)

  var loop_description = `${item.loop_var} from ${item.start_val} while`

  if (item.end_val) {
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
      <ListItem button onClick={handleClick}>
        <ListItemText primary={loop_description} />
        {open ? <ExpandLess /> : <ExpandMore />}
      </ListItem>
      {!isEmpty(item.children) && (
        <Collapse in={open} timeout="auto" unmountOnExit>
          <List component="div" disablePadding>
            {item.children.map((child) => (
              (function () {
                switch (child.type) {
                  case 'CcSequence':
                    return (
                      <ListItem className={classes.nested}>
                        <SequenceItem instrumentId={instrumentId} id={child.id} type={child.type} title={child.type} children={get(child, 'children', [])} />
                      </ListItem>)
                  case 'CcQuestion':
                    return (
                      <ListItem className={classes.nested}>
                        <QuestionListItem instrumentId={instrumentId} id={child.id} type={child.type} />
                      </ListItem>)
                  case 'CcCondition':
                    return (
                      <ListItem className={classes.nested}>
                        <ConditionItem instrumentId={instrumentId} id={child.id} type={child.type} children={get(child, 'children', [])} />
                      </ListItem>)
                  case 'CcLoop':
                    return (
                      <ListItem className={classes.nested}>
                        <LoopItem instrumentId={instrumentId} id={child.id} type={child.type} />
                      </ListItem>)
                  case 'CcStatement':
                    return (
                      <ListItem button className={classes.nested}>
                        <StatementListItem instrumentId={instrumentId} id={child.id} type={child.type} />
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
    <Paper className={classes.control}>
      <List
        component="nav"
        aria-labelledby="nested-list-subheader"
        className={classes.root}
      >
        <ListItem button >
          <Grid item xs={6}>
            <ListItemText primary={title} />
          </Grid>
          <Grid item xs={5}>
            <SequenceTopicsFinder instrumentId={instrumentId} sequence={item} />
          </Grid>
          <Grid item xs={1}>
            {open ? <ExpandLess onClick={handleClick} /> : <ExpandMore onClick={handleClick} />}
          </Grid>
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
                              <QuestionListItem instrumentId={instrumentId} id={child.id} type={child.type} />
                            </ListItem>)
                      case 'CcCondition':
                        return (
                            <ListItem button className={classes.nested}>
                              <ConditionItem instrumentId={instrumentId} id={child.id} type={child.type} />
                            </ListItem>)
                      case 'CcLoop':
                        return (
                          <ListItem button className={classes.nested}>
                            <LoopItem instrumentId={instrumentId} id={child.id} type={child.type} />
                          </ListItem>)
                      case 'CcStatement':
                        return (
                          <ListItem button className={classes.nested}>
                            <StatementListItem instrumentId={instrumentId} id={child.id} type={child.type} />
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
    </Paper>
  );
}

const InstrumentMap = (props) => {

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
      dispatch(CcLoops.all(instrumentId)),
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

  const sequence = (isEmpty(cc_sequences)) ? undefined : Object.values(cc_sequences).find(element => element.top === true)

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Maps'} instrumentId={instrumentId}>
        <InstrumentHeading instrument={instrument} mode={'map'} />
        <Grid container spacing={3}>
          <Grid item xs={10}></Grid>
          <Grid item xs={2}>
            <a href={`${process.env.REACT_APP_API_HOST}/instruments/${instrumentId}/all_mappings.txt?token=${window.localStorage.getItem('jwt')}`}>
              <Chip icon={<DescriptionIcon />} variant="outlined" color="primary" label={'Download File'}></Chip>
            </a>
          </Grid>
        </Grid>
        {!dataLoaded
        ? <Loader />
        : <SequenceItem instrumentId={instrumentId} type={'CcSequence'} id={sequence.children[0].id} title={sequence.children[0].label} children={sequence.children[0].children}/>
      }
      </Dashboard>
    </div>
  );
}

export default InstrumentMap;

import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Instrument, CcConditions, CcLoops, CcSequences, CcStatements, CcQuestions, QuestionItems, QuestionGrids, Variables, Topics, ResponseUnits } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { CcConditionForm } from '../components/CcConditionForm'
import { CcQuestionForm } from '../components/CcQuestionForm'
import { CcStatementForm } from '../components/CcStatementForm'
import { CcSequenceForm } from '../components/CcSequenceForm'
import { CcLoopForm } from '../components/CcLoopForm'
import { ObjectColour } from '../support/ObjectColour'
import { get, isEmpty, isNil } from "lodash";
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/Paper';

import { makeStyles } from '@material-ui/core/styles';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import Badge from '@material-ui/core/Badge';
import Collapse from '@material-ui/core/Collapse';
import DoneIcon from '@material-ui/icons/Done';
import ExpandLess from '@material-ui/icons/ExpandLess';
import ExpandMore from '@material-ui/icons/ExpandMore';
import Chip from '@material-ui/core/Chip';
import Autocomplete from '@material-ui/lab/Autocomplete';
import InputLabel from '@material-ui/core/InputLabel';
import Select from '@material-ui/core/Select';
import BounceLoader from "react-spinners/BounceLoader";
import SyncLoader from "react-spinners/SyncLoader";
import { Box } from '@material-ui/core'
import AddIcon from '@material-ui/icons/Add';
import DeleteIcon from '@material-ui/icons/Delete';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import ExpandLessIcon from '@material-ui/icons/ExpandLess';

import SearchBar from "material-ui-search-bar";

import {
  Button,
  ButtonGroup,
  TextField,
  Divider
} from '@material-ui/core';

import {
  Alert,
  AlertTitle
} from '@material-ui/lab';

import SortableTree, { addNodeUnderParent, removeNodeAtPath, getFlatDataFromTree, changeNodeAtPath, toggleExpandedForAll } from 'react-sortable-tree';
import 'react-sortable-tree/style.css'; // This only needs to be imported once in your app

const TreeNode = (instrumentId, type, id) => {
  var item = ObjectFinder(instrumentId, type, id)
  if(item.type === "condition"){
    var children = get(item, 'children',[])
    var fchildren = get(item, 'fchildren',[])

    var trueAndFalse = [
      { title: `True`, expanded: true, conditionId: item.id, type: 'conditionTrue', children: children.map(child => TreeNode(instrumentId, child.type, child.id)) },
      { title: `False`, expanded: true, conditionId: item.id, type: 'conditionFalse', children: fchildren.map(child => TreeNode(instrumentId, child.type, child.id)) },
    ]
    return {...item, ...{ title: `${item.label}`, expanded: true, type: item.type, children: trueAndFalse } }
  }else{
    var children = get(item, 'children',[])

    return {...item, ...{ title: `${item.label}`, expanded: true, type: item.type, children: children.map(child => TreeNode(instrumentId, child.type, child.id)) } }
  }
}

const TreeNodeFormatter = (instrumentId, item) => {
  return {...item, ...{ title: `${item.label}`, expanded: true, type: item.type } }
}

const Tree = (props) => {
  const { topSequence, instrumentId, dispatch, onNodeSelect } = props
  const [treeData, setTreeData] = useState([TreeNode(instrumentId, 'CcSequence', topSequence.id)]);
  const [selectedNode, setSelectedNode] = useState({});
//  const [expanded, setExpanded] = useState(true);
  const classes = useStyles();

  const [searchString, setSearchString] = useState();
  const [searchFocusIndex, setSearchFocusIndex] = useState();
  const [searchFoundCount, setSearchFoundCount] = useState();

  // Case insensitive search of `node.title`
  const customSearchMethod = ({ node, searchQuery }) =>
    searchQuery &&
    node.title.toLowerCase().indexOf(searchQuery.toLowerCase()) > -1;

  const selectPrevMatch = () =>
      setSearchFocusIndex(
        searchFocusIndex !== null
          ? (searchFoundCount + searchFocusIndex - 1) % searchFoundCount
          : searchFoundCount - 1
      );

  const selectNextMatch = () =>
    setSearchFocusIndex(
        searchFocusIndex !== null
          ? (searchFocusIndex + 1) % searchFoundCount
          : 0,
    );

  const getNodeKey = ({ treeIndex }) => treeIndex;

  const updateNode = ({ node, path }) => {
    var data = changeNodeAtPath({
        treeData: treeData,
        path,
        getNodeKey,
        newNode: TreeNodeFormatter(instrumentId, node)
      })
      setTreeData(data)
      reorderConstructs(data)
  }

  const deleteNode = ({ path }) => {
    onNodeSelect({})
    setTreeData(removeNodeAtPath({
                    treeData: treeData,
                    path,
                    getNodeKey,
    }));
  }

  const canHaveChildren = (node) => {
    return (node.type === 'sequence' || node.type === 'loop' || node.type === 'conditionTrue' || node.type === 'conditionFalse')
  }

  const canDrop = ({ node, nextParent, prevPath, nextPath }) => {
    if (canHaveChildren(nextParent)) {
      return true;
    }

    return false;
  };

  const toggleExpand = (expanded) => {
    setTreeData(toggleExpandedForAll({
                    treeData: treeData,
                    expanded: expanded
    }));
  }

  const orderArray = (data) => {
    return getFlatDataFromTree({
      treeData: data,
      getNodeKey: ({ node }) => { return { id: node.id, type: node.type, children: node.children.map(child => `type ${child.type} id ${child.id}` ) } }, // This ensures your "id" properties are exported in the path
      ignoreCollapsed: false, // Makes sure you traverse every node in the tree, not just the visible ones
    }).map(({ node, path }) => {
      if(['conditionTrue', 'conditionFalse'].includes(node.type)){
        return null
      }
      let parent = path[path.length - 2]
      let branch = (parent !== undefined && parent.type === 'conditionFalse') ? 1 : 0
      if(parent !== undefined && ['conditionTrue', 'conditionFalse'].includes(parent.type)){
        parent = path[path.length - 3]
      }
      return {
        id: node.id,
        type: node.type,
        position: (parent !== undefined) ? parent.children.indexOf(`type ${node.type} id ${node.id}`) + 1 : node.position,
        branch: branch,
        // // The last entry in the path is this node's key
        // // The second to last entry (accessed here) is the parent node's key
        parent: (parent !== undefined) ? { id: parent.id, type: parent.type } : {},
    }}).filter(el => el != null);
  }

  const reorderConstructs = (data) => {
    dispatch(Instrument.reorderConstructs(instrumentId, orderArray(data)));
  }

  const generateButtons = (node, path) => {
      var buttons = []
      if(canHaveChildren(node)){
        buttons.push(
              <button
              onClick={(event) => {
                  setTreeData(addNodeUnderParent({
                    treeData: treeData,
                    parentKey: path[path.length - 1],
                    expandParent: true,
                    getNodeKey,
                    newNode: {
                      title: `Click to select construct type`,
                      children: []
                    }
                  }).treeData)
                  event.stopPropagation()
                  setSelectedNode({node: { type: undefined }})
              }}
            >
              <AddIcon />
            </button>
        )
      }
      return buttons;
  }

  return (
    <div style={{ height: 10000 }}>

    <SearchBar
      placeholder="Search (press return to perform search)"
      onRequestSearch={(newValue) =>
              setSearchString(newValue)
            }
      onCancelSearch={() => {
              setSearchString()
            }}
    />

    {searchFoundCount === 0 && !isNil(searchString) && (
      <Alert severity="error">
        <AlertTitle>Error</AlertTitle>
        No results found.
      </Alert>
    )}

    {searchFoundCount > 0 && !isNil(searchString) && (
      <>
        <span>
          &nbsp;
          {searchFoundCount > 0 ? searchFocusIndex + 1 : 0}
          &nbsp;of&nbsp;
          {searchFoundCount || 0} matches
        </span>
        <ButtonGroup color="primary" aria-label="outlined primary button group">
          <Button onClick={selectPrevMatch}>&lt; Prev</Button>
          <Button onClick={selectNextMatch}>&gt; Next</Button>
        </ButtonGroup>
      </>
    )}

      <Divider className={classes.divider}/>

      <ButtonGroup color="primary" aria-label="outlined primary button group">
        <Button onClick={()=>{toggleExpand(true)}} startIcon={<ExpandMoreIcon />}>Expand All</Button>
        <Button onClick={()=>{toggleExpand(false)}} startIcon={<ExpandLessIcon />}>Collapse All</Button>
      </ButtonGroup>

      <SortableTree
        treeData={treeData}
        onChange={newTreeData => { setTreeData(newTreeData); reorderConstructs(newTreeData) } }
        canNodeHaveChildren={node => canHaveChildren(node)}
        canDrop={canDrop}
        canDrag={({node}) =>{
          return !['conditionTrue', 'conditionFalse'].includes(node.type)
        }}
        searchMethod={customSearchMethod}
        searchQuery={searchString}
        searchFocusOffset={searchFocusIndex}
        searchFinishCallback={(matches) => {
          setSearchFoundCount(matches.length)
          setSearchFocusIndex(matches.length > 0 ? searchFocusIndex % matches.length : 0)
        }}
        generateNodeProps={({ node, path }) => {
          const boxShadow = (node === selectedNode ) ? `5px 5px 15px 5px  #${ObjectColour(node.type)}` : ''
          return (
            {
              style: {
                boxShadow: boxShadow,
              },
              onClick: () => {
                onNodeSelect({ node: node, path: path,  callback: ({ node, path }) => { updateNode({ node, path }) }, deleteCallback: ({ path }) => { deleteNode({ path }) } });
                setSelectedNode(node);
              },
              buttons: generateButtons(node, path),
            }
          )
        }}
      />
    </div>
  );
}

const useStyles = makeStyles((theme) => ({
  root: {
    width: '100%',
    backgroundColor: theme.palette.background.paper
  },
  control: {
    width: '100%',
    padding: theme.spacing(2),
  },
  main: {
    'min-height': '1200px'
  },
  side: {
    position: 'absolute',
    width: '50%',
    right: '5px'
  },
  nested: {
    paddingLeft: theme.spacing(4),
  },
  paper:{
    boxShadow :`5px 5px 10px 5px  #${ObjectColour('default')}`
  },
  statement:{
    boxShadow :`2px 2px 7px 2px  #${ObjectColour('statement')}`,
    'margin-bottom': '10px'
  },
  sequence:{
    boxShadow :`2px 2px 7px 2px  #${ObjectColour('sequence')}`,
    'margin-bottom': '10px'
  },
  question:{
    boxShadow :`2px 2px 7px 2px  #${ObjectColour('question')}`,
    'margin-bottom': '10px'
  },
  loop:{
    boxShadow :`2px 2px 7px 2px  #${ObjectColour('loop')}`,
    'margin-bottom': '10px'
  },
  condition:{
    boxShadow :`2px 2px 7px 2px  #${ObjectColour('condition')}`,
    'margin-bottom': '10px'
  },
  divider:{
    margin: '25px'
  }
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
  const loops = useSelector(state => state.cc_loops);
  const cc_loops = get(loops, instrumentId, {})
  const questions = useSelector(state => state.cc_questions);
  const cc_questions = get(questions, instrumentId, {})
  const allQuestionItems = useSelector(state => state.questionItems);
  const questionItems = get(allQuestionItems, instrumentId, {})
  const allQuestionGrids = useSelector(state => state.questionGrids);
  const questionGrids = get(allQuestionGrids, instrumentId, {})

  var item = {children: []}

  if(type === 'CcLoop'){
    item = get(cc_loops, id.toString(), {})
    item.type = 'loop'
  }

  if(type === 'CcSequence'){
    item = get(cc_sequences, id.toString(), {})
    item.type = 'sequence'
  }

  if(type === 'CcStatement'){
    item = get(cc_statements, id.toString(), {})
    item.type = 'statement'
  }

  if(type === 'CcCondition'){
    item = get(cc_conditions, id.toString(), {})
    item.type = 'condition'
  }

  if(type === 'CcQuestion'){
    item = get(cc_questions, id.toString(), {})

    if(item.question_type === 'QuestionItem'){
      item.question = get(questionItems, item.question_id.toString(), {})
    }else if(item.question_type === 'QuestionGrid'){
      item.question = get(questionGrids, item.question_id.toString(), {})
    }
    item.type = 'question'
  }

  return item

}

const ConstructForm = (props) => {
  const {object, instrumentId, onNodeSelect} = props;
  const { node={}, path, callback=(node)=>{ console.log('No onChange callback provided')}, deleteCallback=(node)=>{ console.log('No onDelete callback provided')} } = object;

  switch (node.type) {
    case 'question':
      return <CcQuestionForm ccQuestion={node} instrumentId={instrumentId} path={path} onChange={callback} onDelete={deleteCallback} />
    case 'statement':
      return <CcStatementForm ccStatement={node} instrumentId={instrumentId} path={path} onChange={callback} onDelete={deleteCallback} />
    case 'sequence':
      return <CcSequenceForm ccSequence={node} instrumentId={instrumentId} path={path} onChange={callback} onDelete={deleteCallback} />
    case 'condition':
      return <CcConditionForm ccCondition={node} instrumentId={instrumentId} path={path} onChange={callback} onDelete={deleteCallback} />
    case 'loop':
      return <CcLoopForm ccLoop={node} instrumentId={instrumentId} path={path} onChange={callback} onDelete={deleteCallback} />
    case undefined:
      return <NewConstructQuestion onNodeSelect={onNodeSelect} object={object}/>
    default:
      return ''
  }

}

const NewConstructQuestion = (props) => {
  const {object, onNodeSelect} = props;

  const classes = useStyles();

  return (
            <Paper style={{ padding: 16 }} className={classes.paper}>
              <h3>Select construct type</h3>
                  <Button
                    type="button"
                    variant="outlined"
                    className={classes.question}
                    onClick={() => {
                      var node = {...object.node, ...{ type: 'question' }}
                      onNodeSelect({...object, ...{node: node }})
                    }}
                  >
                    Question
                  </Button>
                  <br/>
                  <Button
                    type="button"
                    variant="outlined"
                    className={classes.condition}
                    onClick={() => {
                      var node = {...object.node, ...{ type: 'condition' }}
                      onNodeSelect({...object, ...{node: node }})
                    }}
                  >
                    Condition
                  </Button>
                  <br/>
                  <Button
                    type="button"
                    variant="outlined"
                    className={classes.loop}
                    onClick={() => {
                      var node = {...object.node, ...{ type: 'loop' }}
                      onNodeSelect({...object, ...{node: node }})
                    }}
                  >
                    Loop
                  </Button>
                  <br/>
                  <Button
                    type="button"
                    variant="outlined"
                    className={classes.sequence}
                    onClick={() => {
                      var node = {...object.node, ...{ type: 'sequence' }}
                      onNodeSelect({...object, ...{node: node }})
                    }}
                  >
                    Sequence
                  </Button>
                  <br/>
                  <Button
                    type="button"
                    variant="outlined"
                    className={classes.statement}
                    onClick={() => {
                      var node = {...object.node, ...{ type: 'statement' }}
                      onNodeSelect({...object, ...{node: node }})
                    }}
                  >
                    Statement
                  </Button>
          </Paper>
  )

}

const InstrumentConstructBuild = (props) => {

  const classes = useStyles();

  const dispatch = useDispatch()
  const instrumentId = get(props, "match.params.instrument_id", "")
  const instrument = useSelector(state => get(state.instruments, instrumentId));
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

  const [selectedNode, setSelectedNode] = useState({});

  useEffect(() => {
    dispatch(Instrument.show(instrumentId));
    dispatch(CcSequences.all(instrumentId));
    dispatch(CcStatements.all(instrumentId));
    dispatch(CcConditions.all(instrumentId));
    dispatch(CcLoops.all(instrumentId));
    dispatch(CcQuestions.all(instrumentId));
    dispatch(QuestionItems.all(instrumentId));
    dispatch(QuestionGrids.all(instrumentId));
    dispatch(ResponseUnits.all(instrumentId));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  const sequence = (isEmpty(cc_sequences)) ? undefined : Object.values(cc_sequences).find(element => element.top == true)

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Build'} instrumentId={instrumentId}>
        <h1>{get(instrument, 'label')}</h1>
      {isNil(sequence) || isEmpty(statements)  || isEmpty(conditions) || isEmpty(questionItems)  || isEmpty(questions)
        ? <Box m="auto"><BounceLoader color={'#009de6'}/></Box>
        : (
          <Grid container spacing={3} className={classes.main}>
            <Grid item xs={(isEmpty(selectedNode)) ? 12 : 12 }>
              <Tree topSequence={sequence.children[0]} instrumentId={instrumentId} onNodeSelect={setSelectedNode} dispatch={dispatch} />
            </Grid>
            {!isEmpty(selectedNode) && (
              <Grid item xs={4} className={classes.side}>
                <ConstructForm object={selectedNode} instrumentId={instrumentId} onNodeSelect={setSelectedNode} />
              </Grid>
            )}
          </Grid>
        )
      }
      </Dashboard>
    </div>
  );
}

export default InstrumentConstructBuild;

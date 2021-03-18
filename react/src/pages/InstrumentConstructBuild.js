import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Instrument, CcConditions, CcLoops, CcSequences, CcStatements, CcQuestions, QuestionItems, QuestionGrids, ResponseUnits, InstrumentTree } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { MoveConstructSelect } from '../components/MoveConstructSelect'
import { CcConditionForm } from '../components/CcConditionForm'
import { CcQuestionForm } from '../components/CcQuestionForm'
import { CcStatementForm } from '../components/CcStatementForm'
import { CcSequenceForm } from '../components/CcSequenceForm'
import { CcLoopForm } from '../components/CcLoopForm'
import { Loader } from '../components/Loader'
import { ObjectColour } from '../support/ObjectColour'
import { get, isEmpty, isNil } from "lodash";
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/Paper';

import { makeStyles } from '@material-ui/core/styles';
import AddIcon from '@material-ui/icons/Add';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import ExpandLessIcon from '@material-ui/icons/ExpandLess';
import OpenWithIcon from '@material-ui/icons/OpenWith';

import SearchBar from "material-ui-search-bar";

import {
  Button,
  ButtonGroup,
  Divider
} from '@material-ui/core';

import {
  Alert,
  AlertTitle
} from '@material-ui/lab';

import SortableTree, { addNodeUnderParent, removeNodeAtPath, getFlatDataFromTree, changeNodeAtPath, toggleExpandedForAll } from 'react-sortable-tree';
import 'react-sortable-tree/style.css'; // This only needs to be imported once in your app

const TreeNode = (instrumentId, type, id, expanded=false) => {
  var item = ObjectFinder(instrumentId, type, id)
  var children;

  if(item.type === "condition"){
    children = get(item, 'children',[])
    var fchildren = get(item, 'fchildren',[])

    var trueAndFalse = [
      { title: `True`, expanded: expanded, conditionId: item.id, type: 'conditionTrue', children: children.map(child => TreeNode(instrumentId, child.type, child.id)) },
      { title: `False`, expanded: expanded, conditionId: item.id, type: 'conditionFalse', children: fchildren.map(child => TreeNode(instrumentId, child.type, child.id)) },
    ]
    return {...item, ...{ title: `${item.label}`, expanded: expanded, type: item.type, children: trueAndFalse } }
  }else{
    children = get(item, 'children',[])

    return {...item, ...{ title: `${item.label}`, expanded: expanded, type: item.type, children: children.map(child => TreeNode(instrumentId, child.type, child.id)) } }
  }
}

const TreeNodeFormatter = (instrumentId, item) => {
  return {...item, ...{ title: `${item.label}`, expanded: true, type: item.type } }
}

const Tree = (props) => {
  const { topSequence, instrumentId, dispatch, onNodeSelect } = props
  const [treeData, setTreeData] = useState([TreeNode(instrumentId, 'CcSequence', topSequence.id, true)]);
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
    if (!isNil(nextParent) && canHaveChildren(nextParent)) {
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

  const moveableNodesArray = (data) => {
    return getFlatDataFromTree({
      treeData: data,
      getNodeKey: ({ node }) => { return { id: node.id, type: node.type } }, // This ensures your "id" properties are exported in the path
      ignoreCollapsed: false, // Makes sure you traverse every node in the tree, not just the visible ones
    }).map(({ node, path }) => {
      if(!canHaveChildren(node)){
        return null
      }
      if(['conditionTrue', 'conditionFalse'].includes(node.type)){
        return null
      }
      return {
        id: node.id,
        type: node.type,
        title: node.title,
        path: path
      }
    }).filter(el => el != null);
  }

  dispatch(InstrumentTree.create(instrumentId, moveableNodesArray(treeData)));

  const orderArray = (data) => {
    return getFlatDataFromTree({
      treeData: data,
      getNodeKey: ({ node }) => { return { id: node.id, type: node.type, children: node.children.map(child => `type ${child.type} id ${child.id}` ) } }, // This ensures your "id" properties are exported in the path
      ignoreCollapsed: false, // Makes sure you traverse every node in the tree, not just the visible ones
    }).map(({ node, path }) => {
      if(['conditionTrue', 'conditionFalse'].includes(node.type)){
        if(node.id === 172015 || node.id === 36397 || node.id === 36396){
          console.log('nope')
        }
        return null
      }
      let parent = path[path.length - 2]
      let branch = (parent !== undefined && parent.type === 'conditionFalse') ? 1 : 0
      let position = (parent !== undefined) ? parent.children.indexOf(`type ${node.type} id ${node.id}`) + 1 : node.position
      if(parent !== undefined && ['conditionTrue', 'conditionFalse'].includes(parent.type)){
        parent = path[path.length - 3]
      }
      const data = {
        id: node.id,
        type: node.type,
        position: position,
        branch: branch,
        // // The last entry in the path is this node's key
        // // The second to last entry (accessed here) is the parent node's key
        parent: (parent !== undefined) ? { id: parent.id, type: parent.type } : {},
      }

      return data
    }).filter(el => el != null);
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
          const boxShadow = (node === selectedNode || node.type == 'sequence' ) ? `0px 0px 15px 3px  #${ObjectColour(node.type)}` : ''

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
              className: `${node.type}:${node.id}`
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

// This a WIP section to allows a node to moved to another parent
// useful when you want to move a construct outside of the virtualised portal.
const MoveConstructForm = ({instrumentId}) => {
  return <MoveConstructSelect instrumentId={instrumentId} onMove={(event, value)=>{ console.log(value)}}/>
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
  const cc_sequences = get(sequences, instrumentId, null)

  const [selectedNode, setSelectedNode] = useState({});
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
      dispatch(ResponseUnits.all(instrumentId))
    ]).then(() => {
      setDataLoaded(true)
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  const sequence = (isEmpty(cc_sequences) || isNil(cc_sequences)) ? undefined : Object.values(cc_sequences).find(element => element.top == true)

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Build'} instrumentId={instrumentId}>
        <h1>{get(instrument, 'label')}</h1>
      {!dataLoaded
        ? <Loader />
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

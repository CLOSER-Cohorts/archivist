import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Instrument, CcConditions, CcSequences, CcStatements, CcQuestions, QuestionItems, QuestionGrids, Variables, Topics } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { CcConditionForm } from '../components/CcConditionForm'
import { CcQuestionForm } from '../components/CcQuestionForm'
import { CcStatementForm } from '../components/CcStatementForm'
import { CcSequenceForm } from '../components/CcSequenceForm'
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
import TextField from '@material-ui/core/TextField';
import FormControl from '@material-ui/core/FormControl';
import InputLabel from '@material-ui/core/InputLabel';
import Select from '@material-ui/core/Select';
import { Alert, AlertTitle } from '@material-ui/lab';
import BounceLoader from "react-spinners/BounceLoader";
import SyncLoader from "react-spinners/SyncLoader";
import { Box } from '@material-ui/core'
import AddIcon from '@material-ui/icons/Add';
import DeleteIcon from '@material-ui/icons/Delete';

import SortableTree, { addNodeUnderParent, removeNodeAtPath, getFlatDataFromTree, changeNodeAtPath } from 'react-sortable-tree';
import 'react-sortable-tree/style.css'; // This only needs to be imported once in your app

const TreeNode = (instrumentId, type, id) => {
  var item = ObjectFinder(instrumentId, type, id)
  var children = get(item, 'children',[])

  return {...item, ...{ title: item.label, expanded: true, type: item.type, children: children.map(child => TreeNode(instrumentId, child.type, child.id)) } }
}

const TreeNodeFormatter = (instrumentId, item) => {
  return {...item, ...{ title: item.label, expanded: true, type: item.type } }
}

const Tree = (props) => {
  const { topSequence, instrumentId, dispatch, onNodeSelect } = props
  const [treeData, setTreeData] = useState([TreeNode(instrumentId, 'CcSequence', topSequence.id)]);

  const getNodeKey = ({ treeIndex }) => treeIndex;

  const updateNode = ({ node, path }) => {
    setTreeData(
      changeNodeAtPath({
        treeData: treeData,
        path,
        getNodeKey,
        newNode: TreeNodeFormatter(instrumentId, node)
      })
    )
  }

  const deleteNode = ({ path }) => {
    setTreeData(removeNodeAtPath({
                    treeData: treeData,
                    path,
                    getNodeKey,
    }));
  }

  const canHaveChildren = (node) => {
    return (node.type === 'sequence' || node.type === 'loop' || node.type === 'condition')
  }

  const canDrop = ({ node, nextParent, prevPath, nextPath }) => {
    if (canHaveChildren(nextParent)) {
      return true;
    }

    return false;
  };

  const orderArray = (data) => {
    return getFlatDataFromTree({
      treeData: data,
      getNodeKey: ({ node }) => { return { id: node.id, type: node.type, children: node.children.map(child => `type ${child.type} id ${child.id}` ) } }, // This ensures your "id" properties are exported in the path
      ignoreCollapsed: false, // Makes sure you traverse every node in the tree, not just the visible ones
    }).map(({ node, path }) => {
      let parent = path[path.length - 2]
      return {
        id: node.id,
        type: node.type,
        position: (parent !== undefined) ? parent.children.indexOf(`type ${node.type} id ${node.id}`) + 1 : node.position,
        branch: path.length - 1,
        // // The last entry in the path is this node's key
        // // The second to last entry (accessed here) is the parent node's key
        parent: path.length > 1 ? { id: path[path.length - 2].id, type: path[path.length - 2].type } : {},
    }});
  }

  const reorderConstructs = (data) => {
      dispatch(Instrument.reorderConstructs(instrumentId, orderArray(data)));
  }

  const generateButtons = (node, path) => {
      var buttons = []
      if(canHaveChildren(node)){
        buttons.push(
              <button
              onClick={() =>
                  setTreeData(addNodeUnderParent({
                    treeData: treeData,
                    parentKey: path[path.length - 1],
                    expandParent: true,
                    getNodeKey,
                    newNode: {
                      title: `New`,
                    }
                  }).treeData)
              }
            >
              <AddIcon />
            </button>
        )
      }
      return buttons;
  }

  return (
    <div style={{ height: 10000 }}>
      <SortableTree
        treeData={treeData}
        onChange={newTreeData => { setTreeData(newTreeData); reorderConstructs(newTreeData) } }
        canDrop={canDrop}
        generateNodeProps={({ node, path }) => ({
          onClick: () => { onNodeSelect({ node: node, path: path, callback: ({ node, path }) => { updateNode({ node, path }) } }) },
          buttons: generateButtons(node, path),
        })}
      />
      ↓This flat data is generated from the modified tree data↓
      <ul>
      </ul>
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
  side: {
    position: 'absolute',
    width: '50%',
    'margin-left': '46%'
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
  const {object, instrumentId} = props;
  const { node={}, path, callback=(node)=>{ console.log(node)} } = object;

  switch (node.type) {
    case 'question':
      return <CcQuestionForm ccQuestion={node} instrumentId={instrumentId} path={path} onChange={callback} />
    case 'statement':
      return <CcStatementForm ccStatement={node} instrumentId={instrumentId} path={path} onChange={callback} />
    case 'sequence':
      return <CcSequenceForm ccSequence={node} instrumentId={instrumentId} path={path} onChange={callback} />
    case 'condition':
      return <CcConditionForm ccCondition={node} instrumentId={instrumentId} path={path} onChange={callback} />
    default:
      return ''
  }

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

  const [selectedNode, setSelectedNode] = useState({});

  useEffect(() => {
    dispatch(Instrument.show(instrumentId));
    dispatch(CcSequences.all(instrumentId));
    dispatch(CcStatements.all(instrumentId));
    dispatch(CcConditions.all(instrumentId));
    dispatch(CcQuestions.all(instrumentId));
    dispatch(QuestionItems.all(instrumentId));
    dispatch(QuestionGrids.all(instrumentId));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  const sequence = (isEmpty(cc_sequences)) ? undefined : Object.values(cc_sequences).find(element => element.top == true)

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Build'}>
        <h1>{get(instrument, 'label')}</h1>
      {isNil(sequence) || isEmpty(statements)  || isEmpty(conditions) || isEmpty(questionItems) || isEmpty(questionGrids)  || isEmpty(questions)
        ? <Box m="auto"><BounceLoader color={'#009de6'}/></Box>
        : (
          <Grid container spacing={3}>
            <Grid item xs={(isEmpty(selectedNode)) ? 12 : 12 }>
              <Tree topSequence={sequence.children[0]} instrumentId={instrumentId} onNodeSelect={setSelectedNode} dispatch={dispatch} />
            </Grid>
            {!isEmpty(selectedNode) && (
              <Grid item xs={4} className={classes.side}>
                <ConstructForm object={selectedNode} instrumentId={instrumentId} />
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

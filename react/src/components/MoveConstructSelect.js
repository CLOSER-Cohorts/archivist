/* eslint-disable no-use-before-define */
import React, { useState, useEffect } from 'react';
import TextField from '@material-ui/core/TextField';
import Autocomplete from '@material-ui/lab/Autocomplete';
import { makeStyles } from '@material-ui/core/styles';
import { isNil } from "lodash";
import { addNodeUnderParent, removeNodeAtPath, getFlatDataFromTree, isDescendant } from 'react-sortable-tree';

const useStyles = makeStyles({
  option: {
    fontSize: 15,
    '& > span': {
      marginRight: 10,
      fontSize: 18,
    },
  },
});

export const MoveConstructSelect = ({treeData, onChange=()=>{}}) => {
  const classes = useStyles();

  const getNodeKey= ({ node }) => {
    // For conditions the id will be nil so we use the title
    return (isNil(node.id)) ? node.title : node.id
  }

  const flatTree = getFlatDataFromTree({
      treeData: treeData,
      getNodeKey,
      ignoreCollapsed: false, // Makes sure you traverse every node in the tree, not just the visible ones
    })

  const [nodeToMove, setNodeToMove] = useState()
  const [parentNode, setParentNode] = useState()

  const moveNode = () => {
    var node = nodeToMove.node

    onChange(addNodeUnderParent({
      treeData: removeNodeAtPath({
        treeData: treeData,
        path: nodeToMove.path,
        getNodeKey
      }),
      parentKey: parentNode.path[parentNode.path.length - 1],
      expandParent: true,
      getNodeKey,
      newNode: node
    }).treeData)

    setNodeToMove(undefined)
    setParentNode(undefined)
  }

  useEffect(() => {
    if(!isNil(nodeToMove) && !isNil(parentNode)){
      moveNode()
    }
  },[parentNode])

  const onNodeChange = (event, values) => {
    setNodeToMove(values)
  }

  const onParentNodeChange = (event, values) => {
    setParentNode(values)
  }

  const canMove = (node) => {
    return node !== flatTree[0].node && !['conditionTrue', 'conditionFalse'].includes(node.type)
  }

  const canHaveChildren = (node) => {
    return (node.type === 'sequence' || node.type === 'loop' || node.type === 'conditionTrue' || node.type === 'conditionFalse') && !isDescendant(nodeToMove.node, node)
  }

  return (
    <>
      <Autocomplete
        id="country-select-demo"
        options={flatTree.filter((el) => canMove(el.node))}
        onChange={onNodeChange}
        classes={{
          option: classes.option,
        }}
        autoHighlight
        getOptionLabel={(option) => option.node.title}
        renderOption={(option) => (
          <React.Fragment>
            {option.node.title}
          </React.Fragment>
        )}
        renderInput={(params) => (
          <TextField
            {...params}
            label="Construct to move"
            variant="outlined"
            inputProps={{
              ...params.inputProps,
              autoComplete: 'new-password', // disable autocomplete and autofill
            }}
          />
        )}
      />
      { !isNil(nodeToMove) && (
        <Autocomplete
          id="country-select-demo"
          options={flatTree.filter((el) => canHaveChildren(el.node))}
          onChange={onParentNodeChange}
          classes={{
            option: classes.option,
          }}
          autoHighlight
          getOptionLabel={(option) => option.node.title}
          renderOption={(option) => (
            <React.Fragment>
              {option.node.title}
            </React.Fragment>
          )}
          renderInput={(params) => (
            <TextField
              {...params}
              label="Move to parent construct"
              variant="outlined"
              inputProps={{
                ...params.inputProps,
                autoComplete: 'new-password', // disable autocomplete and autofill
              }}
            />
          )}
        />
      ) }
    </>
  );
}

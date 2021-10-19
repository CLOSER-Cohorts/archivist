import React from 'react'
import {isNil} from 'lodash'
import { useDispatch } from 'react-redux'

import {
  Grid,
  Button
} from '@material-ui/core';

export const DeleteObjectButton = (props) => {
  const {instrumentId, id, action, onDelete= () => { console.log('No delete callback provided') }} = props;

  const dispatch=useDispatch()

  const handleDelete = () => {
    if( !isNil(id) && window.confirm('Are you sure you want to delete this?')){
      dispatch(action.delete(instrumentId, id, onDelete))
    }
  }

  if(isNil(id)){
    return ''
  }

  return (
    <Grid item style={{ marginTop: 16 }}>
      <Button
        variant="contained"
        color="secondary"
        onClick={()=>{handleDelete()}}
      >
        Delete
      </Button>
    </Grid>
  )
}

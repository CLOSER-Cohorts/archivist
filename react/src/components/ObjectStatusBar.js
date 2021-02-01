import React from 'react';
import { useSelector, useDispatch } from 'react-redux'
import { Alert, AlertTitle } from '@material-ui/lab';
import { isEmpty, isNil, get } from 'lodash'

export const ObjectStatus = (id, type) => {
  const statuses = useSelector(state => state.statuses);
  const key = type + ':' + id
  return get(statuses, key, {})
}

export const ObjectStatusBar = (props) => {
  const {id, type} = props
  const status = ObjectStatus(id, type)

  if(!isEmpty(status) && !isNil(status.error)){
    return (
      <div>
        <Alert severity="error">
          <AlertTitle>Error</AlertTitle>
          {status.errorMessage}
        </Alert>
      </div>
    )
  }else{
    return ''
  }
}

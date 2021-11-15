import React from 'react';
import Button from '@material-ui/core/Button';
import ButtonGroup from '@material-ui/core/ButtonGroup';
import { useHistory } from 'react-router-dom';
import AddIcon from '@material-ui/icons/Add';
import { reverse as url } from 'named-urls'
import routes from '../routes'

const ObjectTypeLookup = (objectType, instrumentId) => {
    switch(objectType) {
      case('ResponseDomainNumeric'):
        return {
          path: url(routes.instruments.instrument.build.responseDomains.show, { instrument_id: instrumentId, responseDomainType: objectType, responseDomainId: 'new' }),
          text: 'Numeric'
        }
      case('ResponseDomainText'):
        return {
          path: url(routes.instruments.instrument.build.responseDomains.show, { instrument_id: instrumentId, responseDomainType: objectType, responseDomainId: 'new' }),
          text: 'Text'
        }
      case('ResponseDomainDatetime'):
        return {
          path: url(routes.instruments.instrument.build.responseDomains.show, { instrument_id: instrumentId, responseDomainType: objectType, responseDomainId: 'new' }),
          text: 'Datetime'
        }
      case('CodeList'):
        return {
          path: url(routes.instruments.instrument.build.codeLists.show, { instrument_id: instrumentId, codeListId: 'new' }),
          text: 'New CodeList'
        }
      case('QuestionItem'):
        return {
          path: url(routes.instruments.instrument.build.questionItems.show, { instrument_id: instrumentId, questionItemId: 'new' }),
          text: 'Question Item'
        }
      case('QuestionGrid'):
        return {
          path: url(routes.instruments.instrument.build.questionGrids.show, { instrument_id: instrumentId, questionGridId: 'new' }),
          text: 'Question Grid'
        }
      default:
        return {
          path: '/',
          text: 'Not found'
        }
  }
}

export const CreateNewBuildObjectButtons  = (props) => {
  const { objectTypes=[], instrumentId, callback=()=>{}} = props;

  const history = useHistory();

  const createNew = (path) => {
    history.push(path);
    callback('new')
  }

  const buttons = objectTypes.map( objectType => ObjectTypeLookup(objectType, instrumentId) )

  return (
    <ButtonGroup color="primary" aria-label="outlined primary button group">
     {buttons.map((button) => {
        return <Button onClick={()=> { createNew(button.path)} }startIcon={<AddIcon />}>{button.text}</Button>
      })}
    </ButtonGroup>
  )
}

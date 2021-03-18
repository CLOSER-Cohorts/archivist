import axios from "axios";
import { reverse as url } from 'named-urls'
import routes from '../routes'

const api_host = process.env.REACT_APP_API_HOST

const api_headers = () => ({
          'Authorization': 'Bearer ' + window.localStorage.getItem('jwt'),
          'Content-Type': 'application/json'
        })

axios.interceptors.response.use(function (response) {
    return response;
}, function (error) {
    if (401 === error.response.status) {
      window.localStorage.removeItem('jwt');
      window.location = '/login'
    } else {
        return Promise.reject(error);
    }
});

// Auth
export const authUser = (email, password) => {
  const request = axios.post(api_host + '/users/sign_in.json', {
      "user": {
              "email": email,
              "password": password
      }
    })
  return (dispatch) => {
      return request.then(res => {
        dispatch(authUserSuccess(res.data));
      })
      .catch(err => {
        dispatch(authUserFailure(err.message));
      });
  };
};

export const InstrumentTree = {
  create: (instrumentId, flatTree) => {
    return (dispatch) => {
        dispatch({type: 'LOAD_INSTRUMENT_TREE', payload: { instrumentId: instrumentId, flatTree: flatTree }});
    };
  }
}

export const Dataset = {
  all: () => {
    const request = axios.get(api_host + '/datasets.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(datasetsFetchSuccess(res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  show: (id) => {
    const request = axios.get(api_host + '/datasets/' + id + '.json?questions=true',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(datasetFetchSuccess(res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  }
}

export const AdminInstrument = {
  create: (values) => {
    let formData = new FormData();

    formData.append("files[]", values.files[0]);
    const request = axios.post(api_host + '/admin/import/instruments/', formData, {
        headers: {...api_headers(), ...{'Content-Type': 'multipart/form-data'}}
      })
    return (dispatch) => {
        dispatch(savingItem('new', 'AdminInstrument'));
        return request.then(res => {
          dispatch(savedItem('new', 'AdminInstrument'));
        })
        .catch(err => {
          console.log('error')
        });
    };
  },
}

export const AdminDataset = {
  create: (values) => {
    let formData = new FormData();

    formData.append("files[]", values.files[0]);
    const request = axios.post(api_host + '/admin/import/datasets/', formData, {
        headers: {...api_headers(), ...{'Content-Type': 'multipart/form-data'}}
      })
    return (dispatch) => {
        dispatch(savingItem('new', 'AdminDataset'));
        return request.then(res => {
          dispatch(savedItem('new', 'AdminDataset'));
        })
        .catch(err => {
          console.log('error')
        });
    };
  },
}

export const AdminImportMapping = {
  create: (type, id, values) => {
    let formData = new FormData();

    values.imports.map((imp) => {
      formData.append('imports[0][file]', imp.file)
    })
    const request = axios.post(api_host + '/' + type + '/' + id + '/imports.json', formData, {
        headers: {...api_headers(), ...{'Content-Type': 'multipart/form-data'}}
      })
    return (dispatch) => {
        dispatch(savingItem('new', 'AdminImportMappings'));
        return request.then(res => {
          dispatch(savedItem('new', 'AdminImportMappings'));
        })
        .catch(err => {
          console.log('error')
        });
    };
  },
  all: (type, id) => {
    const request = axios.get(api_host + '/' + type + '/' + id + '/imports.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(importsFetchSuccess(res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
}

export const AdminImport = {
  all: () => {
    const request = axios.get(api_host + '/imports.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(importsFetchSuccess(res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  show: (id) => {
    const request = axios.get(api_host + '/imports/' + id + '.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(importFetchSuccess(res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
}

export const Instrument = {
  update: (instrumentId, values) => {
    const request = axios.put(api_host + '/instruments/' + instrumentId + '.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(instrumentId, 'Instrument'));
        return request.then(res => {
          dispatch(savedItem(instrumentId, 'Instrument'));
          dispatch(instrumentFetchSuccess(res.data));
        })
        .catch(err => {
          dispatch(saveError(instrumentId, 'Instrument', err.response.data.error_sentence));
        });
    };
  },
  create: (values) => {
    const request = axios.post(api_host + '/instruments.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem('new', 'Instrument'));
        return request.then(res => {
          dispatch(savedItem('new', 'Instrument'));
          dispatch(instrumentFetchSuccess(res.data));
          dispatch(redirectTo(url(routes.instruments.instrument.show, { instrument_id: res.data.prefix })));
        })
        .catch(err => {
          dispatch(saveError('new', 'Instrument', err.response.data.error_sentence));
        });
    };
  },
  import: (values) => {
    const request = axios.post(api_host + '/admin/import/instruments/', { updates: values }, {
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          console.log('ok')
        })
        .catch(err => {
          console.log('error')
        });
    };
  },
  all: () => {
    const request = axios.get(api_host + '/instruments.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(instrumentsFetchSuccess(res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  show: (id) => {
    const request = axios.get(api_host + '/instruments/' + id + '.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(instrumentFetchSuccess(res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  stats: (id) => {
    const request = axios.get(api_host + '/instruments/' + id + '/stats.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(instrumentStatsFetchSuccess(id, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  reorderConstructs: (instrumentId, values) => {
    const request = axios.post(api_host + '/instruments/' + instrumentId + '/reorder_ccs.json', { updates: values }, {
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          console.log('ok')
        })
        .catch(err => {
          console.log('error')
        });
    };
  }
}

export const Categories = {
  all: (instrumentId) => {
    const request = axios.get(api_host + '/instruments/' + instrumentId + '/categories.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(categoriesFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  }
}

const categoriesFetchSuccess = (instrumentId, categories) => ({
  type: 'LOAD_INSTRUMENT_CATEGORIES',
  payload: {
    instrumentId: instrumentId,
    categories: categories
  }
});

export const CodeLists = {
  all: (instrumentId) => {
    const request = axios.get(api_host + '/instruments/' + instrumentId + '/code_lists.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(codeListsFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  update: (instrumentId, codeListId, values) => {
    const request = axios.put(api_host + '/instruments/' + instrumentId + '/code_lists/' + codeListId + '.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(codeListId, 'CodeList'));
        return request.then(res => {
          dispatch(savedItem(codeListId, 'CodeList'));
          dispatch(codeListFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(saveError(codeListId, 'CodeList', err.response.data.error_sentence));
        });
    };
  },
  create: (instrumentId, values) => {
    const request = axios.post(api_host + '/instruments/' + instrumentId + '/code_lists.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem('new', 'CodeList'));
        return request.then(res => {
          dispatch(savedItem('new', 'CodeList'));
          dispatch(codeListFetchSuccess(instrumentId, res.data));
          dispatch(redirectTo(url(routes.instruments.instrument.build.codeLists.show, { instrument_id: instrumentId, codeListId: res.data.id })));
        })
        .catch(err => {
          dispatch(saveError('new', 'CodeList', err.response.data.error_sentence));
        });
    };
  },
  delete: (instrumentId, codeListId) => {
    const request = axios.delete(api_host + '/instruments/' + instrumentId + '/code_lists/' + codeListId + '.json', {
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(objectDeleteSuccess(instrumentId,'CodeList', codeListId));
          dispatch(redirectTo(url(routes.instruments.instrument.build.codeLists.all, { instrument_id: instrumentId })));
        })
        .catch(err => {
          dispatch(savedItem(codeListId, 'CodeList'));
          dispatch(saveError(codeListId, 'CodeList', err.response.data.error_sentence));
        });
    };
  }
}

const codeListsFetchSuccess = (instrumentId, codeLists) => ({
  type: 'LOAD_INSTRUMENT_CODE_LISTS',
  payload: {
    instrumentId: instrumentId,
    codeLists: codeLists
  }
});

const codeListFetchSuccess = (instrumentId, codeList) => ({
  type: 'LOAD_INSTRUMENT_CODE_LIST',
  payload: {
    instrumentId: instrumentId,
    codeList: codeList
  }
});

export const CcSequences = {
  all: (instrumentId) => {
    const request = axios.get(api_host + '/instruments/' + instrumentId + '/cc_sequences.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(ccSequencesFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  update: (instrumentId, ccSequenceId, values) => {
    const request = axios.put(api_host + '/instruments/' + instrumentId + '/cc_sequences/' + ccSequenceId + '.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(ccSequenceId, 'CcSequence'));
        return request.then(res => {
          dispatch(savedItem(ccSequenceId, 'CcSequence'));
          dispatch(ccSequenceFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(saveError(ccSequenceId, 'CcSequence', err.response.data));
        });
    };
  },
  create: (instrumentId, values, onSuccess=(object)=>{}) => {
    const request = axios.post(api_host + '/instruments/' + instrumentId + '/cc_sequences.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem('new', 'CcSequence'));
        return request.then(res => {
          dispatch(savedItem('new', 'CcSequence'));
          dispatch(ccSequenceFetchSuccess(instrumentId, res.data));
          onSuccess({id:res.data.id})
        })
        .catch(err => {
          dispatch(saveError('new', 'CcSequence', err.response.data));
        });
    };
  },
  delete: (instrumentId, ccSequenceId, onDelete=()=>{}) => {
    const request = axios.delete(api_host + '/instruments/' + instrumentId + '/cc_sequences/' + ccSequenceId + '.json', {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(ccSequenceId, 'CcSequence'));
        return request.then(res => {
          dispatch(savedItem(ccSequenceId, 'CcSequence'));
          dispatch(objectDeleteSuccess(instrumentId,'CcSequence', ccSequenceId));
          onDelete();
        })
        .catch(err => {
          dispatch(saveError(ccSequenceId, 'CcSequence', err.response.data));
        });
    };
  },
}

const ccSequencesFetchSuccess = (instrumentId, sequences) => ({
  type: 'LOAD_INSTRUMENT_SEQUENCES',
  payload: {
    instrumentId: instrumentId,
    sequences: sequences
  }
});

const ccSequenceFetchSuccess = (instrumentId, sequence) => ({
  type: 'LOAD_INSTRUMENT_SEQUENCE',
  payload: {
    instrumentId: instrumentId,
    sequence: sequence
  }
});

export const CcStatements = {
  all: (instrumentId) => {
    const request = axios.get(api_host + '/instruments/' + instrumentId + '/cc_statements.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(ccStatementsFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  update: (instrumentId, ccStatementId, values) => {
    const request = axios.put(api_host + '/instruments/' + instrumentId + '/cc_statements/' + ccStatementId + '.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(ccStatementId, 'CcStatement'));
        return request.then(res => {
          dispatch(savedItem(ccStatementId, 'CcStatement'));
          dispatch(ccStatementFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(saveError(ccStatementId, 'CcStatement', err.response.data));
        });
    };
  },
  create: (instrumentId, values, onSuccess=(object)=>{}) => {
    const request = axios.post(api_host + '/instruments/' + instrumentId + '/cc_statements.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem('new', 'CcStatement'));
        return request.then(res => {
          dispatch(savedItem('new', 'CcStatement'));
          dispatch(ccStatementFetchSuccess(instrumentId, res.data));
          onSuccess({id:res.data.id})
        })
        .catch(err => {
          dispatch(saveError('new', 'CcStatement', err.response.data));
        });
    };
  },
  delete: (instrumentId, ccStatementId, onDelete=()=>{}) => {
    const request = axios.delete(api_host + '/instruments/' + instrumentId + '/cc_statements/' + ccStatementId + '.json', {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(ccStatementId, 'CcStatement'));
        return request.then(res => {
          dispatch(savedItem(ccStatementId, 'CcStatement'));
          dispatch(objectDeleteSuccess(instrumentId,'CcStatement', ccStatementId));
          onDelete()
        })
        .catch(err => {
          dispatch(saveError(ccStatementId, 'CcStatement', err.response.data));
        });
    };
  },
}

const ccStatementsFetchSuccess = (instrumentId, statements) => ({
  type: 'LOAD_INSTRUMENT_STATEMENTS',
  payload: {
    instrumentId: instrumentId,
    statements: statements
  }
});

const ccStatementFetchSuccess = (instrumentId, statement) => ({
  type: 'LOAD_INSTRUMENT_STATEMENT',
  payload: {
    instrumentId: instrumentId,
    statement: statement
  }
});

export const CcLoops = {
  all: (instrumentId) => {
    const request = axios.get(api_host + '/instruments/' + instrumentId + '/cc_loops.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(ccLoopsFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  update: (instrumentId, ccLoopId, values) => {
    const request = axios.put(api_host + '/instruments/' + instrumentId + '/cc_loops/' + ccLoopId + '.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(ccLoopId, 'CcLoop'));
        return request.then(res => {
          dispatch(savedItem(ccLoopId, 'CcLoop'));
          dispatch(ccLoopFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(saveError(ccLoopId, 'CcLoop', err.response.data.error_sentence));
        });
    };
  },
  create: (instrumentId, values, onSuccess=(object)=>{}) => {
    const request = axios.post(api_host + '/instruments/' + instrumentId + '/cc_loops.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem('new', 'CcLoop'));
        return request.then(res => {
          dispatch(savedItem('new', 'CcLoop'));
          dispatch(ccLoopFetchSuccess(instrumentId, res.data));
          onSuccess({id:res.data.id})
        })
        .catch(err => {
          dispatch(saveError('new', 'CcLoop', err.response.data.error_sentence));
        });
    };
  },
  delete: (instrumentId, ccLoopId, onDelete=()=>{}) => {
    const request = axios.delete(api_host + '/instruments/' + instrumentId + '/cc_loops/' + ccLoopId + '.json', {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(ccLoopId, 'CcLoop'));
        return request.then(res => {
          dispatch(savedItem(ccLoopId, 'CcLoop'));
          dispatch(objectDeleteSuccess(instrumentId,'CcLoop', ccLoopId));
          onDelete();
        })
        .catch(err => {
          dispatch(saveError(ccLoopId, 'CcLoop', err.response.data.error_sentence));
        });
    };
  },
}

const ccLoopsFetchSuccess = (instrumentId, loops) => ({
  type: 'LOAD_INSTRUMENT_LOOPS',
  payload: {
    instrumentId: instrumentId,
    loops: loops
  }
});

const ccLoopFetchSuccess = (instrumentId, loop) => ({
  type: 'LOAD_INSTRUMENT_LOOP',
  payload: {
    instrumentId: instrumentId,
    loop: loop
  }
});

export const ResponseUnits = {
  all: (instrumentId) => {
    const request = axios.get(api_host + '/instruments/' + instrumentId + '/response_units.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(responseUnitsFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  update: (instrumentId, responseUnitId, values) => {
    const request = axios.put(api_host + '/instruments/' + instrumentId + '/response_units/' + responseUnitId + '.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(responseUnitFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(saveError(responseUnitId, 'ResponseUnit', err.response.data.error_sentence));
        });
    };
  },
  create: (instrumentId, values) => {
    const request = axios.post(api_host + '/instruments/' + instrumentId + '/response_units.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(responseUnitFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(saveError('new', 'ResponseUnit', err.response.data.error_sentence));
        });
    };
  },
  delete: (instrumentId, responseUnitId, onDelete=()=>{}) => {
    const request = axios.delete(api_host + '/instruments/' + instrumentId + '/response_units/' + responseUnitId + '.json', {
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(objectDeleteSuccess(instrumentId,'ResponseUnit', responseUnitId));
          onDelete();
        })
        .catch(err => {
          dispatch(saveError(responseUnitId, 'ResponseUnit', err.response.data.error_sentence));
        });
    };
  },
}

const responseUnitsFetchSuccess = (instrumentId, responseUnits) => ({
  type: 'LOAD_INSTRUMENT_RESPONSE_UNITS',
  payload: {
    instrumentId: instrumentId,
    responseUnits: responseUnits
  }
});

const responseUnitFetchSuccess = (instrumentId, responseUnit) => ({
  type: 'LOAD_INSTRUMENT_RESPONSE_UNITS',
  payload: {
    instrumentId: instrumentId,
    responseUnit: responseUnit
  }
});

export const CcConditions = {
  all: (instrumentId) => {
    const request = axios.get(api_host + '/instruments/' + instrumentId + '/cc_conditions.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(ccConditionsFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  update: (instrumentId, ccConditionId, values) => {
    const request = axios.put(api_host + '/instruments/' + instrumentId + '/cc_conditions/' + ccConditionId + '.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(ccConditionId, 'CcCondition'));
        return request.then(res => {
          dispatch(savedItem(ccConditionId, 'CcCondition'));
          dispatch(ccConditionFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(saveError(ccConditionId, 'CcCondition', err.response.data));
        });
    };
  },
  create: (instrumentId, values, onSuccess=(object)=>{}) => {
    const request = axios.post(api_host + '/instruments/' + instrumentId + '/cc_conditions.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem('new', 'CcCondition'));
        return request.then(res => {
          dispatch(savedItem('new', 'CcCondition'));
          dispatch(ccConditionFetchSuccess(instrumentId, res.data));
          onSuccess({id:res.data.id})
        })
        .catch(err => {
          dispatch(saveError('new', 'CcCondition', err.response.data));
        });
    };
  },
  delete: (instrumentId, ccConditionId, onDelete=()=>{}) => {
    const request = axios.delete(api_host + '/instruments/' + instrumentId + '/cc_conditions/' + ccConditionId + '.json', {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(ccConditionId, 'CcCondition'));
        return request.then(res => {
          dispatch(savedItem(ccConditionId, 'CcCondition'));
          dispatch(objectDeleteSuccess(instrumentId,'CcCondition', ccConditionId));
          onDelete()
        })
        .catch(err => {
          dispatch(saveError(ccConditionId, 'CcCondition', err.response.data));
        });
    };
  },
}

const ccConditionsFetchSuccess = (instrumentId, conditions) => ({
  type: 'LOAD_INSTRUMENT_CONDITIONS',
  payload: {
    instrumentId: instrumentId,
    conditions: conditions
  }
});

const ccConditionFetchSuccess = (instrumentId, condition) => ({
  type: 'LOAD_INSTRUMENT_CONDITION',
  payload: {
    instrumentId: instrumentId,
    condition: condition
  }
});

export const CcQuestions = {
  all: (instrumentId) => {
    const request = axios.get(api_host + '/instruments/' + instrumentId + '/cc_questions.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(ccQuestionsFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  update: (instrumentId, ccQuestionId, values) => {
    const request = axios.put(api_host + '/instruments/' + instrumentId + '/cc_questions/' + ccQuestionId + '.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(ccQuestionId, 'CcQuestion'));
        return request.then(res => {
          dispatch(savedItem(ccQuestionId, 'CcQuestion'));
          dispatch(ccQuestionFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(saveError(ccQuestionId, 'CcQuestion', err.response.data));
        });
    };
  },
  create: (instrumentId, values, onSuccess=(object)=>{}) => {
    const request = axios.post(api_host + '/instruments/' + instrumentId + '/cc_questions.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem('new', 'CcQuestion'));
        return request.then(res => {
          dispatch(savedItem('new', 'CcQuestion'));
          dispatch(ccQuestionFetchSuccess(instrumentId, res.data));
          onSuccess({id:res.data.id})
        })
        .catch(err => {
          dispatch(saveError('new', 'CcQuestion', err.response.data));
        });
    };
  },
  delete: (instrumentId, ccQuestionId, onDelete=()=>{}) => {
    const request = axios.delete(api_host + '/instruments/' + instrumentId + '/cc_questions/' + ccQuestionId + '.json', {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(ccQuestionId, 'CcQuestion'));
        return request.then(res => {
          dispatch(savedItem(ccQuestionId, 'CcQuestion'));
          dispatch(objectDeleteSuccess(instrumentId,'CcQuestion', ccQuestionId));
          onDelete();
        })
        .catch(err => {
          dispatch(saveError(ccQuestionId, 'CcQuestion', err.response.data));
        });
    };
  },
  topic: {
    set: (instrumentId, ccQuestionId, topicId) => {
      const request = axios.post(api_host + '/instruments/' + instrumentId + '/cc_questions/' + ccQuestionId + '/set_topic.json',
      {
        "topic_id": topicId
      },
      {
          headers: api_headers()
        })
      return (dispatch) => {
          dispatch(savingItem(ccQuestionId, 'CcQuestion'));
          return request.then(res => {
            dispatch(savedItem(ccQuestionId, 'CcQuestion'));
            dispatch(ccQuestionFetchSuccess(instrumentId, res.data));
          })
          .catch(err => {
            dispatch(saveError(ccQuestionId, 'CcQuestion', err.response.data.message));
          });
      };
    }
  },
  variables: {
    add: (instrumentId, ccQuestionId, variableNames) => {
      const request = axios.post(api_host + '/instruments/' + instrumentId + '/cc_questions/' + ccQuestionId + '/add_variables.json',
      {
        "variable_names": variableNames
      },
      {
          headers: api_headers()
        })
      return (dispatch) => {
          dispatch(savingItem(ccQuestionId, 'CcQuestion'));
          return request.then(res => {
            dispatch(savedItem(ccQuestionId, 'CcQuestion'));
            dispatch(ccQuestionFetchSuccess(instrumentId, res.data));
          })
          .catch(err => {
            dispatch(saveError(ccQuestionId, 'CcQuestion', err.response.data.message));
          });
      };
    },
    remove: (instrumentId, ccQuestionId, variableId) => {
      const request = axios.post(api_host + '/instruments/' + instrumentId + '/cc_questions/' + ccQuestionId + '/remove_variable.json',
      {
        "variable_id": variableId
      },
      {
          headers: api_headers()
        })
      return (dispatch) => {
          dispatch(savingItem(ccQuestionId, 'CcQuestion'));
          return request.then(res => {
            dispatch(savedItem(ccQuestionId, 'CcQuestion'));
            dispatch(ccQuestionFetchSuccess(instrumentId, res.data));
          })
          .catch(err => {
            dispatch(saveError(ccQuestionId, 'CcQuestion', err.message));
          });
      };
    }
  }
}

const savingItem = (id, type) => ({
  type: 'SAVING',
  payload: {
    id: id,
    type: type
  }
});

const savedItem = (id, type) => ({
  type: 'SAVED',
  payload: {
    id: id,
    type: type
  }
});

const ccQuestionsFetchSuccess = (instrumentId, questions) => ({
  type: 'LOAD_INSTRUMENT_QUESTIONS',
  payload: {
    instrumentId: instrumentId,
    questions: questions
  }
});

const ccQuestionFetchSuccess = (instrumentId, question) => ({
  type: 'LOAD_INSTRUMENT_QUESTION',
  payload: {
    instrumentId: instrumentId,
    question: question
  }
});

export const QuestionItems = {
  all: (instrumentId) => {
    const request = axios.get(api_host + '/instruments/' + instrumentId + '/question_items.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(questionItemsFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  update: (instrumentId, questionItemId, values) => {
    const request = axios.put(api_host + '/instruments/' + instrumentId + '/question_items/' + questionItemId + '.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(questionItemId, 'QuestionItem'));
        return request.then(res => {
          dispatch(savedItem(questionItemId, 'QuestionItem'));
          dispatch(questionItemFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(saveError(questionItemId, 'QuestionItem', err.response.data.error_sentence));
        });
    };
  },
  create: (instrumentId, values) => {
    const request = axios.post(api_host + '/instruments/' + instrumentId + '/question_items.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem('new', 'QuestionItem'));
        return request.then(res => {
          dispatch(savedItem('new', 'QuestionItem'));
          dispatch(questionItemFetchSuccess(instrumentId, res.data));
          dispatch(redirectTo(url(routes.instruments.instrument.build.questionItems.show, { instrument_id: instrumentId, questionItemId: res.data.id })));
        })
        .catch(err => {
          dispatch(saveError('new', 'QuestionItem', err.response.data.error_sentence));
        });
    };
  },
  delete: (instrumentId, questionItemId) => {
    const request = axios.delete(api_host + '/instruments/' + instrumentId + '/question_items/' + questionItemId + '.json', {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(questionItemId, 'QuestionItem'));
        return request.then(res => {
          dispatch(savedItem(questionItemId, 'QuestionItem'));
          dispatch(objectDeleteSuccess(instrumentId,'QuestionItem', questionItemId));
          dispatch(redirectTo(url(routes.instruments.instrument.build.questionItems.all, { instrument_id: instrumentId })));
        })
        .catch(err => {
          dispatch(saveError(questionItemId, 'QuestionItem', err.response.data.error_sentence));
        });
    };
  }
}

const questionItemsFetchSuccess = (instrumentId, questions) => ({
  type: 'LOAD_INSTRUMENT_QUESTION_ITEMS',
  payload: {
    instrumentId: instrumentId,
    questions: questions
  }
});

const questionItemFetchSuccess = (instrumentId, questionItem) => ({
  type: 'LOAD_INSTRUMENT_QUESTION_ITEM',
  payload: {
    instrumentId: instrumentId,
    questionItem: questionItem
  }
});

export const QuestionGrids = {
  all: (instrumentId) => {
    const request = axios.get(api_host + '/instruments/' + instrumentId + '/question_grids.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(questionGridsFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  update: (instrumentId, questionGridId, values) => {
    const request = axios.put(api_host + '/instruments/' + instrumentId + '/question_grids/' + questionGridId + '.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(questionGridId, 'QuestionGrid'));
        return request.then(res => {
          dispatch(savedItem(questionGridId, 'QuestionGrid'));
          dispatch(questionGridFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(saveError(questionGridId, 'QuestionGrid', err.response.data.error_sentence));
        });
    };
  },
  create: (instrumentId, values) => {
    const request = axios.post(api_host + '/instruments/' + instrumentId + '/question_grids.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem('new', 'QuestionGrid'));
        return request.then(res => {
          dispatch(savedItem('new', 'QuestionGrid'));
          dispatch(questionGridFetchSuccess(instrumentId, res.data));
          dispatch(redirectTo(url(routes.instruments.instrument.build.questionGrids.show, { instrument_id: instrumentId, questionGridId: res.data.id })));
        })
        .catch(err => {
          dispatch(saveError('new', 'QuestionGrid', err.response.data.error_sentence));
        });
    };
  },
  delete: (instrumentId, questionGridId) => {
    const request = axios.delete(api_host + '/instruments/' + instrumentId + '/question_grids/' + questionGridId + '.json', {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(questionGridId, 'QuestionGrid'));
        return request.then(res => {
          dispatch(savedItem(questionGridId, 'QuestionGrid'));
          dispatch(objectDeleteSuccess(instrumentId,'QuestionGrid', questionGridId));
          dispatch(redirectTo(url(routes.instruments.instrument.build.questionGrids.all, { instrument_id: instrumentId })));
        })
        .catch(err => {
          dispatch(saveError(questionGridId, 'QuestionGrid', err.response.data.error_sentence));
        });
    };
  }
}

const questionGridsFetchSuccess = (instrumentId, questions) => ({
  type: 'LOAD_INSTRUMENT_QUESTION_GRIDS',
  payload: {
    instrumentId: instrumentId,
    questions: questions
  }
});

const questionGridFetchSuccess = (instrumentId, questionGrid) => ({
  type: 'LOAD_INSTRUMENT_QUESTION_GRID',
  payload: {
    instrumentId: instrumentId,
    questionGrid: questionGrid
  }
});

export const ResponseDomainNumerics = {
  all: (instrumentId) => {
    const request = axios.get(api_host + '/instruments/' + instrumentId + '/response_domain_numerics.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(responseDomainNumericsFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  update: (instrumentId, responseDomainNumericId, values) => {
    const request = axios.put(api_host + '/instruments/' + instrumentId + '/response_domain_numerics/' + responseDomainNumericId + '.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(responseDomainNumericId, 'ResponseDomainNumeric'));
        return request.then(res => {
          dispatch(savedItem(responseDomainNumericId, 'ResponseDomainNumeric'));
          dispatch(responseDomainNumericFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(saveError(responseDomainNumericId, 'ResponseDomainNumeric', err.response.data.error_sentence));
        });
    };
  },
  create: (instrumentId, values) => {
    const request = axios.post(api_host + '/instruments/' + instrumentId + '/response_domain_numerics.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem('new', 'ResponseDomainNumeric'));
        return request.then(res => {
          dispatch(savedItem('new', 'ResponseDomainNumeric'));
          dispatch(responseDomainNumericFetchSuccess(instrumentId, res.data));
          dispatch(redirectTo(url(routes.instruments.instrument.build.responseDomains.show, { instrument_id: instrumentId, responseDomainType: res.data.type, responseDomainId: res.data.id })));
        })
        .catch(err => {
          dispatch(saveError('new', 'ResponseDomainNumeric', err.response.data.error_sentence));
        });
    };
  },
  delete: (instrumentId, responseDomainNumericId) => {
    const request = axios.delete(api_host + '/instruments/' + instrumentId + '/response_domain_numerics/' + responseDomainNumericId + '.json', {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(responseDomainNumericId, 'ResponseDomainNumeric'));
        return request.then(res => {
          dispatch(savedItem(responseDomainNumericId, 'ResponseDomainNumeric'));
          dispatch(objectDeleteSuccess(instrumentId,'ResponseDomainNumeric', responseDomainNumericId));
          dispatch(redirectTo(url(routes.instruments.instrument.build.responseDomains.all, { instrument_id: instrumentId })));
        })
        .catch(err => {
          dispatch(saveError(responseDomainNumericId, 'ResponseDomainNumeric', err.response.data.error_sentence));
        });
    };
  }
}

const responseDomainNumericsFetchSuccess = (instrumentId, responseDomainNumerics) => ({
  type: 'LOAD_INSTRUMENT_RESPONSE_DOMAIN_NUMERICS',
  payload: {
    instrumentId: instrumentId,
    responseDomainNumerics: responseDomainNumerics
  }
});

const responseDomainNumericFetchSuccess = (instrumentId, responseDomainNumeric) => ({
  type: 'LOAD_INSTRUMENT_RESPONSE_DOMAIN_NUMERIC',
  payload: {
    instrumentId: instrumentId,
    responseDomainNumeric: responseDomainNumeric
  }
});

export const ResponseDomainCodes = {
  all: (instrumentId) => {
    const request = axios.get(api_host + '/instruments/' + instrumentId + '/response_domain_codes.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(responseDomainCodesFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  }
}

const responseDomainCodesFetchSuccess = (instrumentId, responseDomainCodes) => ({
  type: 'LOAD_INSTRUMENT_RESPONSE_DOMAIN_CODES',
  payload: {
    instrumentId: instrumentId,
    responseDomainCodes: responseDomainCodes
  }
});

export const ResponseDomainTexts = {
  all: (instrumentId) => {
    const request = axios.get(api_host + '/instruments/' + instrumentId + '/response_domain_texts.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(responseDomainTextsFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  update: (instrumentId, responseDomainTextId, values) => {
    const request = axios.put(api_host + '/instruments/' + instrumentId + '/response_domain_texts/' + responseDomainTextId + '.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(responseDomainTextId, 'ResponseDomainText'));
        return request.then(res => {
          dispatch(savedItem(responseDomainTextId, 'ResponseDomainText'));
          dispatch(responseDomainTextFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(saveError(responseDomainTextId, 'ResponseDomainText', err.response.data.error_sentence));
        });
    };
  },
  create: (instrumentId, values) => {
    const request = axios.post(api_host + '/instruments/' + instrumentId + '/response_domain_texts.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem('new', 'ResponseDomainText'));
        return request.then(res => {
          dispatch(savedItem('new', 'ResponseDomainText'));
          dispatch(responseDomainTextFetchSuccess(instrumentId, res.data));
          dispatch(redirectTo(url(routes.instruments.instrument.build.responseDomains.show, { instrument_id: instrumentId, responseDomainType: res.data.type, responseDomainId: res.data.id })));
        })
        .catch(err => {
          dispatch(saveError('new', 'ResponseDomainText', err.response.data.error_sentence));
        });
    };
  },
  delete: (instrumentId, responseDomainTextId) => {
    const request = axios.delete(api_host + '/instruments/' + instrumentId + '/response_domain_texts/' + responseDomainTextId + '.json', {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(responseDomainTextId, 'ResponseDomainText'));
        return request.then(res => {
          dispatch(savedItem(responseDomainTextId, 'ResponseDomainText'));
          dispatch(objectDeleteSuccess(instrumentId,'ResponseDomainText', responseDomainTextId));
          dispatch(redirectTo(url(routes.instruments.instrument.build.responseDomains.all, { instrument_id: instrumentId })));
        })
        .catch(err => {
          dispatch(saveError(responseDomainTextId, 'ResponseDomainText', err.response.data.error_sentence));
        });
    };
  }
}

const responseDomainTextsFetchSuccess = (instrumentId, responseDomainTexts) => ({
  type: 'LOAD_INSTRUMENT_RESPONSE_DOMAIN_TEXTS',
  payload: {
    instrumentId: instrumentId,
    responseDomainTexts: responseDomainTexts
  }
});

const responseDomainTextFetchSuccess = (instrumentId, responseDomainText) => ({
  type: 'LOAD_INSTRUMENT_RESPONSE_DOMAIN_TEXT',
  payload: {
    instrumentId: instrumentId,
    responseDomainText: responseDomainText
  }
});

export const ResponseDomainDatetimes = {
  all: (instrumentId) => {
    const request = axios.get(api_host + '/instruments/' + instrumentId + '/response_domain_datetimes.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(responseDomainDatetimesFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  update: (instrumentId, responseDomainDatetimeId, values) => {
    const request = axios.put(api_host + '/instruments/' + instrumentId + '/response_domain_datetimes/' + responseDomainDatetimeId + '.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(responseDomainDatetimeId, 'ResponseDomainDatetime'));
        return request.then(res => {
          dispatch(savedItem(responseDomainDatetimeId, 'ResponseDomainDatetime'));
          dispatch(responseDomainDatetimeFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(saveError(responseDomainDatetimeId, 'ResponseDomainDatetime', err.response.data.error_sentence));
        });
    };
  },
  create: (instrumentId, values) => {
    const request = axios.post(api_host + '/instruments/' + instrumentId + '/response_domain_datetimes.json', values, {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem('new', 'ResponseDomainDatetime'));
        return request.then(res => {
          dispatch(savedItem('new', 'ResponseDomainDatetime'));
          dispatch(responseDomainDatetimeFetchSuccess(instrumentId, res.data));
          dispatch(redirectTo(url(routes.instruments.instrument.build.responseDomains.show, { instrument_id: instrumentId, responseDomainType: res.data.type, responseDomainId: res.data.id })));
        })
        .catch(err => {
          dispatch(saveError('new', 'ResponseDomainDatetime', err.response.data.error_sentence));
        });
    };
  },
  delete: (instrumentId, responseDomainDatetimeId) => {
    const request = axios.delete(api_host + '/instruments/' + instrumentId + '/response_domain_datetimes/' + responseDomainDatetimeId + '.json', {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(responseDomainDatetimeId, 'ResponseDomainDatetime'));
        return request.then(res => {
          dispatch(savedItem(responseDomainDatetimeId, 'ResponseDomainDatetime'));
          dispatch(objectDeleteSuccess(instrumentId,'ResponseDomainDatetime', responseDomainDatetimeId));
          dispatch(redirectTo(url(routes.instruments.instrument.build.responseDomains.all, { instrument_id: instrumentId })));
        })
        .catch(err => {
          dispatch(saveError(responseDomainDatetimeId, 'ResponseDomainDatetime', err.response.data.error_sentence));
        });
    };
  }
}

const responseDomainDatetimesFetchSuccess = (instrumentId, responseDomainDatetimes) => ({
  type: 'LOAD_INSTRUMENT_RESPONSE_DOMAIN_DATETIMES',
  payload: {
    instrumentId: instrumentId,
    responseDomainDatetimes: responseDomainDatetimes
  }
});

const responseDomainDatetimeFetchSuccess = (instrumentId, responseDomainDatetime) => ({
  type: 'LOAD_INSTRUMENT_RESPONSE_DOMAIN_DATETIME',
  payload: {
    instrumentId: instrumentId,
    responseDomainDatetime: responseDomainDatetime
  }
});

export const Variables = {
  all: (instrumentId) => {
    const request = axios.get(api_host + '/instruments/' + instrumentId + '/variables.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(variablesFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  add: (instrumentId) => {
    const request = axios.get(api_host + '/instruments/' + instrumentId + '/add_variables.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(variablesFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  }
}

const variablesFetchSuccess = (instrumentId, variables) => ({
  type: 'LOAD_INSTRUMENT_VARIABLES',
  payload: {
    instrumentId: instrumentId,
    variables: variables
  }
});

export const DatasetVariable = {
  all: (datasetId) => {
    const request = axios.get(api_host + '/datasets/' + datasetId + '/variables.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(datasetVariablesFetchSuccess(datasetId, res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  },
  add_source: (datasetId, datasetVariableId, sources) => {
    const request = axios.post(api_host + '/datasets/' + datasetId + '/variables/' + datasetVariableId + '/add_sources.json',
    {
      sources: {
        "id": sources,
        "x": null,
        "y": null
      }
    },
    {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(datasetVariableId, 'DatasetVariable'));
        return request.then(res => {
          dispatch(savedItem(datasetVariableId, 'DatasetVariable'));
          dispatch(datasetVariableFetchSuccess(datasetId, res.data));
        })
        .catch(err => {
          dispatch(saveError(datasetVariableId, 'DatasetVariable', err.response.data.message));
        });
    };
  },
  remove_source: (datasetId, datasetVariableId, source) => {
    const request = axios.post(api_host + '/datasets/' + datasetId + '/variables/' + datasetVariableId + '/remove_source.json',
    {
      other: {
        id: source.id,
        class: source.class,
        x: source.x,
        y: source.y
      }
    },
    {
        headers: api_headers()
      })
    return (dispatch) => {
        dispatch(savingItem(datasetVariableId, 'DatasetVariable'));
        return request.then(res => {
          dispatch(savedItem(datasetVariableId, 'DatasetVariable'));
          dispatch(datasetVariableFetchSuccess(datasetId, res.data));
        })
        .catch(err => {
          dispatch(saveError(datasetVariableId, 'DatasetVariable', err.message));
        });
    };
  }
}

const datasetVariablesFetchSuccess = (datasetId, variables) => ({
  type: 'LOAD_DATASET_VARIABLES',
  payload: {
    datasetId: datasetId,
    variables: variables
  }
});

const datasetVariableFetchSuccess = (datasetId, variable) => ({
  type: 'LOAD_DATASET_VARIABLE',
  payload: {
    datasetId: datasetId,
    variable: variable
  }
});

export const Topics = {
  all: () => {
    const request = axios.get(api_host + '/topics/flattened_nest.json',{
        headers: api_headers()
      })
    return (dispatch) => {
        return request.then(res => {
          dispatch(topicsFetchSuccess(res.data));
        })
        .catch(err => {
          dispatch(fetchFailure(err.message));
        });
    };
  }
}

const topicsFetchSuccess = (topics) => ({
  type: 'LOAD_TOPICS',
  payload: {
    topics: topics
  }
});

const datasetsFetchSuccess = datasets => ({
  type: 'LOAD_DATASETS',
  payload: {
    datasets: datasets
  }
});

const datasetFetchSuccess = datasets => ({
  type: 'LOAD_DATASET',
  payload: {
    dataset: datasets
  }
});

const importsFetchSuccess = imports => ({
  type: 'LOAD_ADMIN_IMPORTS',
  payload: {
    imports: imports
  }
});

const importFetchSuccess = importObj => ({
  type: 'LOAD_ADMIN_IMPORT',
  payload: {
    import: importObj
  }
});

const instrumentsFetchSuccess = instruments => ({
  type: 'LOAD_INSTRUMENTS',
  payload: {
    instruments: instruments
  }
});

const instrumentFetchSuccess = instruments => ({
  type: 'LOAD_INSTRUMENT',
  payload: {
    instrument: instruments
  }
});

const instrumentStatsFetchSuccess = (instrumentId, stats) => ({
  type: 'LOAD_INSTRUMENT_STATS',
  payload: {
    instrumentId: instrumentId,
    stats: stats
  }
});

const objectDeleteSuccess = (instrumentId, objectType, id) => ({
  type: 'DELETE_INSTRUMENT_OBJECT_TYPE',
  payload: {
    instrumentId: instrumentId,
    id: id,
    objectType: objectType
  }
});

const fetchFailure = error => ({
  type: 'FETCH_FAILURE',
  payload: {
    error
  }
});

const saveError = (id, type, error) => ({
  type: 'ERROR',
  payload: {
    id: id,
    type: type,
    error: error
  }
});

const authUserSuccess = auth => ({
  type: 'LOGIN',
  payload: {
    ...auth
  }
});

const authUserFailure = error => ({
  type: 'LOGIN_FAILURE',
  payload: {
    error
  }
});

const redirectTo = (url) => ({
  type: 'REDIRECT',
  payload: {
    to: url
  }
})

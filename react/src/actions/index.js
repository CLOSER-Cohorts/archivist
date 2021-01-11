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

export const Instrument = {
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
        return request.then(res => {
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
        return request.then(res => {
          dispatch(codeListFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(saveError('new', 'CodeList', err.response.data.error_sentence));
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
  }
}

const ccSequencesFetchSuccess = (instrumentId, sequences) => ({
  type: 'LOAD_INSTRUMENT_SEQUENCES',
  payload: {
    instrumentId: instrumentId,
    sequences: sequences
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
  }
}

const ccStatementsFetchSuccess = (instrumentId, statements) => ({
  type: 'LOAD_INSTRUMENT_STATEMENTS',
  payload: {
    instrumentId: instrumentId,
    statements: statements
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
  }
}

const ccConditionsFetchSuccess = (instrumentId, conditions) => ({
  type: 'LOAD_INSTRUMENT_CONDITIONS',
  payload: {
    instrumentId: instrumentId,
    conditions: conditions
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
        return request.then(res => {
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
        return request.then(res => {
          dispatch(questionItemFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(saveError('new', 'QuestionItem', err.response.data.error_sentence));
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
        return request.then(res => {
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
        return request.then(res => {
          dispatch(questionGridFetchSuccess(instrumentId, res.data));
        })
        .catch(err => {
          dispatch(saveError('new', 'QuestionGrid', err.response.data.error_sentence));
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
        return request.then(res => {
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
        return request.then(res => {
          dispatch(responseDomainNumericFetchSuccess(instrumentId, res.data));
          dispatch(redirectTo(url(routes.instruments.instrument.build.responseDomains.show, { instrument_id: instrumentId, responseDomainType: res.data.type, responseDomainId: res.data.id })));
        })
        .catch(err => {
          dispatch(saveError('new', 'ResponseDomainNumeric', err.response.data.error_sentence));
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
        return request.then(res => {
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
        return request.then(res => {
          dispatch(responseDomainTextFetchSuccess(instrumentId, res.data));
          dispatch(redirectTo(url(routes.instruments.instrument.build.responseDomains.show, { instrument_id: instrumentId, responseDomainType: res.data.type, responseDomainId: res.data.id })));
        })
        .catch(err => {
          dispatch(saveError('new', 'ResponseDomainText', err.response.data.error_sentence));
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
        return request.then(res => {
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
        return request.then(res => {
          dispatch(responseDomainDatetimeFetchSuccess(instrumentId, res.data));
          dispatch(redirectTo(url(routes.instruments.instrument.build.responseDomains.show, { instrument_id: instrumentId, responseDomainType: res.data.type, responseDomainId: res.data.id })));
        })
        .catch(err => {
          dispatch(saveError('new', 'ResponseDomainDatetime', err.response.data.error_sentence));
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

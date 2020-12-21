import { combineReducers } from "redux";
import { get } from 'lodash'

const serializeSearchesArrayToObject = (array) =>
  array.reduce((obj, item) => {
    obj[item.prefix] = item
   return obj
  }, {})

const serializeArrayToObject = (array) =>
  array.reduce((obj, item) => {
    obj[item.id] = item
   return obj
  }, {})

const auth = (state = { isAuthUser: !!window.localStorage.getItem("jwt") }, action) => {

  switch (action.type) {
    case 'LOGIN':
      window.localStorage.setItem('jwt', action.payload.jwt);
      return { isAuthUser: true }
    case 'LOGOUT':
      window.localStorage.removeItem('jwt');
      return { isAuthUser: false }
    default:
      return state
  }
}

const instruments = (state = [], action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENTS':
      return serializeSearchesArrayToObject(action.payload.instruments)
    case 'LOAD_INSTRUMENT':
      return {...state, ...{[action.payload.instrument.prefix]: action.payload.instrument}}
    default:
      return state
  }
}

const instrumentStats = (state = [], action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_STATS':
      return {...state, ...{[action.payload.instrumentId]: action.payload.stats}}
    default:
      return state
  }
}

const cc_sequences = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_SEQUENCES':
    console.log(action.payload)
    console.log({...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.sequences)}})
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.sequences)}}
    default:
      return state
  }
}

const cc_statements = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_STATEMENTS':
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.statements)}}
    default:
      return state
  }
}

const cc_conditions = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_CONDITIONS':
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.conditions)}}
    default:
      return state
  }
}

const cc_questions = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_QUESTIONS':
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.questions)}}
    case 'LOAD_INSTRUMENT_QUESTION':
      var instrumentQuestions = state[action.payload.instrumentId]
      instrumentQuestions[action.payload.question.id] = action.payload.question
      return {...state, ...{[action.payload.instrumentId]: instrumentQuestions}}
    default:
      return state
  }
}

const questionItems = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_QUESTION_ITEMS':
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.questions)}}
    default:
      return state
  }
}

const questionGrids = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_QUESTION_GRIDS':
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.questions)}}
    default:
      return state
  }
}

const variables = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_VARIABLES':
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.variables)}}
    default:
      return state
  }
}

const codeLists = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_CODE_LISTS':
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.codeLists)}}
    case 'LOAD_INSTRUMENT_CODE_LIST':
      var codeLists = get(state, action.payload.instrumentId, {})
      const revisedCodeLists = {...codeLists, ...{[action.payload.codeList.id]: action.payload.codeList}}
      return {...state, ...{[action.payload.instrumentId]: revisedCodeLists}}
    default:
      return state
  }
}

const categories = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_CATEGORIES':
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.categories)}}
    default:
      return state
  }
}

const topics = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_TOPICS':
      return {...state, ...serializeArrayToObject(action.payload.topics)}
    default:
      return state
  }
}

const statuses = (state = {}, action) => {

  var key;

  switch (action.type) {
    case 'SAVING':
      key = action.payload.type + ':' + action.payload.id
      return {...state, ...{[key]: {saving: true}}}
    case 'SAVED':
      key = action.payload.type + ':' + action.payload.id
      return {...state, ...{[key]: {saved: true}}}
    case 'ERROR':
      key = action.payload.type + ':' + action.payload.id
      return {...state, ...{[key]: {error: true, errorMessage: action.payload.error}}}
    default:
      return state
  }
}

const appReducer = combineReducers({
    auth,
    instruments,
    instrumentStats,
    cc_sequences,
    cc_statements,
    cc_conditions,
    cc_questions,
    questionItems,
    questionGrids,
    categories,
    codeLists,
    variables,
    statuses,
    topics
})

export default appReducer;

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

const imports = (state = [], action) => {

  switch (action.type) {
    case 'LOAD_IMPORTS':
      return serializeSearchesArrayToObject(action.payload.imports)
    case 'LOAD_IMPORT':
      return {...state, ...{[action.payload.import.prefix]: action.payload.import}}
    default:
      return state
  }
}

const datasets = (state = [], action) => {
  switch (action.type) {
    case 'LOAD_DATASETS':
      return serializeArrayToObject(action.payload.datasets)
    case 'LOAD_DATASET':
      return {...state, ...{[action.payload.dataset.id]: action.payload.dataset}}
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
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.sequences)}}
    case 'LOAD_INSTRUMENT_SEQUENCE':
      var instrumentSequences = state[action.payload.instrumentId]
      instrumentSequences[action.payload.sequence.id] = action.payload.sequence
      return {...state, ...{[action.payload.instrumentId]: instrumentSequences}}
    default:
      return state
  }
}

const cc_statements = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_STATEMENTS':
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.statements)}}
    case 'LOAD_INSTRUMENT_STATEMENT':
      var instrumentStatements = state[action.payload.instrumentId]
      instrumentStatements[action.payload.statement.id] = action.payload.statement
      return {...state, ...{[action.payload.instrumentId]: instrumentStatements}}
    default:
      return state
  }
}

const cc_conditions = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_CONDITIONS':
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.conditions)}}
    case 'LOAD_INSTRUMENT_CONDITION':
      var instrumentConditions = state[action.payload.instrumentId]
      instrumentConditions[action.payload.condition.id] = action.payload.condition
      return {...state, ...{[action.payload.instrumentId]: instrumentConditions}}
    default:
      return state
  }
}


const cc_loops = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_LOOPS':
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.loops)}}
    case 'LOAD_INSTRUMENT_LOOP':
      var instrumentLoops = state[action.payload.instrumentId]
      instrumentLoops[action.payload.loop.id] = action.payload.loop
      return {...state, ...{[action.payload.instrumentId]: instrumentLoops}}
    default:
      return state
  }
}

const response_units = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_RESPONSE_UNITS':
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.responseUnits)}}
    case 'LOAD_INSTRUMENT_RESPONSE_UNIT':
      var instrumentResponseUnits = state[action.payload.instrumentId]
      instrumentResponseUnits[action.payload.responseUnit.id] = action.payload.responseUnit
      return {...state, ...{[action.payload.instrumentId]: instrumentResponseUnits}}
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
    case 'LOAD_INSTRUMENT_QUESTION_ITEM':
      var questionItems = get(state, action.payload.instrumentId, {})
      const revisedQuestionItems = {...questionItems, ...{[action.payload.questionItem.id]: action.payload.questionItem}}
      return {...state, ...{[action.payload.instrumentId]: revisedQuestionItems}}
    case 'DELETE_INSTRUMENT_OBJECT_TYPE':
      if(action.payload.objectType === 'QuestionItem'){
        var objects = get(state, action.payload.instrumentId, {})
        delete objects[action.payload.id]
        return {...state, ...{[action.payload.instrumentId]: objects}}
      }else{
        return state
      }
    default:
      return state
  }
}

const questionGrids = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_QUESTION_GRIDS':
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.questions)}}
    case 'LOAD_INSTRUMENT_QUESTION_GRID':
      var questionGrids = get(state, action.payload.instrumentId, {})
      const revisedQuestionGrids = {...questionGrids, ...{[action.payload.questionGrid.id]: action.payload.questionGrid}}
      return {...state, ...{[action.payload.instrumentId]: revisedQuestionGrids}}
    case 'DELETE_INSTRUMENT_OBJECT_TYPE':
      if(action.payload.objectType === 'QuestionGrid'){
        var objects = get(state, action.payload.instrumentId, {})
        delete objects[action.payload.id]
        return {...state, ...{[action.payload.instrumentId]: objects}}
      }else{
        return state
      }
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

const datasetVariables = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_DATASET_VARIABLES':
      return {...state, ...{[action.payload.datasetId]: serializeArrayToObject(action.payload.variables)}}
    case 'LOAD_DATASET_VARIABLE':
      var variables = get(state, action.payload.datasetId, {})
      const revisedVariables = {...variables, ...{[action.payload.variable.id]: action.payload.variable}}
      return {...state, ...{[action.payload.datasetId]: revisedVariables}}
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
    case 'DELETE_INSTRUMENT_OBJECT_TYPE':
      if(action.payload.objectType === 'CodeList'){
        var codeLists = get(state, action.payload.instrumentId, {})
        delete codeLists[action.payload.id]
        return {...state, ...{[action.payload.instrumentId]: codeLists}}
      }else{
        return state
      }
    default:
      return state
  }
}

const responseDomainNumerics = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_RESPONSE_DOMAIN_NUMERICS':
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.responseDomainNumerics)}}
    case 'LOAD_INSTRUMENT_RESPONSE_DOMAIN_NUMERIC':
      var responseDomainNumerics = get(state, action.payload.instrumentId, {})
      const revisedResponseDomains = {...responseDomainNumerics, ...{[action.payload.responseDomainNumeric.id]: action.payload.responseDomainNumeric}}
      return {...state, ...{[action.payload.instrumentId]: revisedResponseDomains}}
    case 'DELETE_INSTRUMENT_OBJECT_TYPE':
      if(action.payload.objectType === 'ResponseDomainNumeric'){
        var objects = get(state, action.payload.instrumentId, {})
        delete objects[action.payload.id]
        return {...state, ...{[action.payload.instrumentId]: objects}}
      }else{
        return state
      }
    default:
      return state
  }
}

const responseDomainTexts = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_RESPONSE_DOMAIN_TEXTS':
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.responseDomainTexts)}}
    case 'LOAD_INSTRUMENT_RESPONSE_DOMAIN_TEXT':
      var responseDomainTexts = get(state, action.payload.instrumentId, {})
      const revisedResponseDomains = {...responseDomainTexts, ...{[action.payload.responseDomainText.id]: action.payload.responseDomainText}}
      return {...state, ...{[action.payload.instrumentId]: revisedResponseDomains}}
    case 'DELETE_INSTRUMENT_OBJECT_TYPE':
      if(action.payload.objectType === 'ResponseDomainText'){
        var objects = get(state, action.payload.instrumentId, {})
        delete objects[action.payload.id]
        return {...state, ...{[action.payload.instrumentId]: objects}}
      }else{
        return state
      }
    default:
      return state
  }
}

const responseDomainDatetimes = (state = {}, action) => {

  switch (action.type) {
    case 'LOAD_INSTRUMENT_RESPONSE_DOMAIN_DATETIMES':
      return {...state, ...{[action.payload.instrumentId]: serializeArrayToObject(action.payload.responseDomainDatetimes)}}
    case 'LOAD_INSTRUMENT_RESPONSE_DOMAIN_DATETIME':
      var responseDomainDatetimes = get(state, action.payload.instrumentId, {})
      const revisedResponseDomains = {...responseDomainDatetimes, ...{[action.payload.responseDomainDatetime.id]: action.payload.responseDomainDatetime}}
      return {...state, ...{[action.payload.instrumentId]: revisedResponseDomains}}
    case 'DELETE_INSTRUMENT_OBJECT_TYPE':
      if(action.payload.objectType === 'ResponseDomainDatetime'){
        var objects = get(state, action.payload.instrumentId, {})
        delete objects[action.payload.id]
        return {...state, ...{[action.payload.instrumentId]: objects}}
      }else{
        return state
      }
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
      if(typeof action.payload.error === 'object' && action.payload.error !== null){
        return {...state, ...{[key]: {error: true, errors: action.payload.error, errorMessage: ''}}}
      }else{
        return {...state, ...{[key]: {error: true, errorMessage: action.payload.error}}}
      }
    default:
      return state
  }
}

const common = (state = {}, action) => {

  switch (action.type) {
    case 'REDIRECT':
      return {...state, ...{redirect: action.payload.to}}
    case 'REDIRECT_CLEAR':
      return {...state, ...{redirect: undefined}}
    default:
      return state
  }
}


const appReducer = combineReducers({
    common,
    auth,
    datasets,
    instruments,
    imports,
    instrumentStats,
    cc_sequences,
    cc_statements,
    cc_conditions,
    cc_loops,
    cc_questions,
    response_units,
    questionItems,
    questionGrids,
    categories,
    codeLists,
    responseDomainNumerics,
    responseDomainTexts,
    responseDomainDatetimes,
    datasetVariables,
    variables,
    statuses,
    topics
})

export default appReducer;

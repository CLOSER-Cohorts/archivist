import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Dataset, DatasetVariable, Topics } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { DatasetHeading } from '../components/DatasetHeading'
import { Loader } from '../components/Loader'
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import TableFooter from '@material-ui/core/TableFooter';
import TablePagination from '@material-ui/core/TablePagination';
import Divider from '@material-ui/core/Divider';
import Autocomplete from '@material-ui/lab/Autocomplete';
import TextField from '@material-ui/core/TextField';
import { get, isEmpty, isNil } from 'lodash'
import { makeStyles } from '@material-ui/core/styles';
import FormControl from '@material-ui/core/FormControl';
import InputLabel from '@material-ui/core/InputLabel';
import Select from '@material-ui/core/Select';
import MenuItem from '@material-ui/core/MenuItem';
import { Alert, AlertTitle } from '@material-ui/lab';
import SearchBar from "material-ui-search-bar";
import { ObjectStatus } from '../components/ObjectStatusBar'

const TopicList = (props) => {
  const {topicId, datasetId, variableId} = props

  const dispatch = useDispatch()

  const topics = useSelector(state => state.topics);
  const topicOptions = [{ id: null, name: '', level: 1 }].concat(Object.values(get(topics, 'flattened', {})));

  const classes = makeStyles((theme) => ({
    root: {
      flexGrow: 1,
    },
    paper: {
      padding: theme.spacing(2),
      textAlign: 'center',
      color: theme.palette.text.secondary,
    },
  }));

  const handleChange = (event, value, reason) => {
    dispatch(DatasetVariable.topic.set(datasetId, variableId, (reason === 'clear') ? null : value.id));
  }

  if (isEmpty(topics) || isEmpty(topics.flattened)) {
    return 'Fetching topics'
  } else if (isNil(topicId)) {
    return (
      <div>
        <Autocomplete
          onChange={handleChange}
          options={topicOptions}
          renderInput={params => (
            <TextField {...params} label="Topic" variant="outlined" />
          )}
          getOptionLabel={option => (option.level === 1) ? option.name : '--' + option.name}
        />
      </div>
    )
  } else {
    return (
      <div>
        <Autocomplete
          onChange={handleChange}
          options={topicOptions}
          renderInput={params => (
            <TextField {...params} label="Topic" variant="outlined" />
          )}
          value={Object.values(topics.flattened).find(topic => { return topic.id == topicId })}
          getOptionLabel={option => (option.level === 1) ? option.name : '--' + option.name}
        />
      </div>
    )
  }
}

const DatasetView = (props) => {

  const dispatch = useDispatch()
  const datasetId = get(props, "match.params.dataset_id", "")

  const statuses = useSelector(state => state.statuses);
  const dataset = useSelector(state => get(state.datasets, datasetId));
  const variables = useSelector(state => get(state.datasetVariables, datasetId,{}));
  const [page, setPage] = React.useState(0);
  const [rowsPerPage, setRowsPerPage] = React.useState(20);
  const [search, setSearch] = useState("");
  const [filteredValues, setFilteredValues] = useState([]);

  useEffect(() => {
    setFilteredValues(
      Object.values(variables).filter((value) => {
        const nameMatch = value['name'] && value['name'].toLowerCase().includes(search.toLowerCase())
        const labelMatch = value['label'] && value['label'].toLowerCase().includes(search.toLowerCase())
        const topic = get(value,'topic', {name: ''})
        const topicMatch = topic && topic['name'] && topic['name'].toLowerCase().includes(search.toLowerCase())
        const sources = get(value,'sources', [])
        const sourcesStr = sources.map((s)=>{ return s['name'] || s['label'] }).join(' ')
        const sourcesMatch = sourcesStr && sourcesStr.toLowerCase().includes(search.toLowerCase())
        const usedBy = get(value, 'used_bys', [])
        const usedByStr = usedBy.map((s) => { return s['name'] || s['label'] }).join(' ')
        const usedByMatch = usedByStr && usedByStr.toLowerCase().includes(search.toLowerCase())
        return nameMatch || labelMatch || topicMatch || sourcesMatch || usedByMatch
      }).sort((el)=> el.id).reverse()
    );
  }, [search, variables]);

  const rows: RowsProp = filteredValues;

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  const [dataLoaded, setDataLoaded] = useState(false);

  useEffect(() => {
    Promise.all([
      dispatch(Dataset.show(datasetId)),
      dispatch(DatasetVariable.all(datasetId)),
      dispatch(Topics.all())
    ]).then(() => {
      setDataLoaded(true)
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  const VariableTableRow = (props) => {
    const { row } = props;

    const status = ObjectStatus(row.id, 'DatasetVariable')

    var errorMessage = null;

    if (status.error) {
      errorMessage = status.errorMessage
    } else if (row.errors) {
      errorMessage = row.errors
    }

    var sourceOptions = (row.var_type == 'Derived') ? variables : get(dataset, 'questions', [])

    return (
      <TableRow key={row.id}>
        <TableCell>{row.id}</TableCell>
        <TableCell>{row.name}</TableCell>
        <TableCell>{row.label}</TableCell>
        <TableCell><VariableTypes sources={[]} variable={row} datasetId={datasetId}/></TableCell>
        <TableCell><VariablesList variables={row.used_bys}/></TableCell>
        <TableCell>
          {(row.var_type == 'Derived') ? (
            <VariableSourcesList sources={row.sources} sourceOptions={sourceOptions} datasetId={datasetId} variable={row} />
          ) : (
            <SourcesList sources={row.sources} sourceOptions={sourceOptions} datasetId={datasetId} variable={row} />
          )}
        </TableCell>
        <TableCell>
          <TopicList topicId={get(row.topic, 'id')} datasetId={datasetId} variableId={row.id} />
          {!isNil(row.sources_topic) && (
            <em>Resolved topic from sources - {get(row.sources_topic, 'name')}</em>
          )}
        </TableCell>
      </TableRow>
    )
  }

  const VariableTypes = (props) => {
    const { sources, datasetId, variable } = props
    var newVariable = variable
    const handleChange = (event, value, reason) => {
      newVariable.var_type = value.props.value
      dispatch(DatasetVariable.update(datasetId, variable.id, newVariable));
    }

    return (
        <Select
          value={variable.var_type}
          onChange={handleChange}>
        >
          <MenuItem value={'Derived'}>{'Derived'}</MenuItem>
          <MenuItem value={'Normal'}>{'Normal'}</MenuItem>
        </Select>
    )
  }

  const VariablesList = (props) => {
    const { variables } = props

    const listItems = variables.map((number) =>
      <li>{number.name}</li>
    );
    return (
      <ul>{listItems}</ul>
    )
  }

  const VariableSourcesList = (props) => {
    const { sources, datasetId, variable } = props

    let { sourceOptions } = props

    if (get(variable.topic, 'id') !== 0 && (!isEmpty(variable.topic) || !isEmpty(variable.sources_topic))) {
      sourceOptions = Object.values(sourceOptions).filter(opt => {
        return (
          get(opt.topic, 'id') == get(variable.topic, 'id') ||
          get(opt.resolved_topic, 'id') == get(variable.topic, 'id') ||
          (get(opt.topic, 'id') === 0 && get(opt.resolved_topic, 'id') === 0) || (opt.topic === null && opt.resolved_topic === null)
        )
      })
    }

    const variableId = variable.id
    const dispatch = useDispatch()

    const handleAddSource = (newSources) => {
      dispatch(DatasetVariable.add_source(datasetId, variableId, newSources));
    }

    const handleRemoveSource = (oldSources) => {
      oldSources.map((source) => {
        dispatch(DatasetVariable.remove_source(datasetId, variableId, source));
      })
    }

    var difference = []

    const handleChange = (event, value, reason) => {
      switch (reason) {
        case 'select-option':
          difference = value.filter(x => !sources.includes(x));
          if (!isEmpty(difference)) {
            return handleAddSource(difference.map((source) => { return source.name }))
          };
          break;
        case 'remove-option':
          difference = sources.filter(x => !value.includes(x));
          if (!isEmpty(difference)) {
            return handleRemoveSource(difference)
          };
          break;
        default:
          return null;
      }
    }

    if (isEmpty(sources)) {
      return (
        <div>
          <Autocomplete
            multiple
            id="tags-outlined"
            options={Object.values(sourceOptions)}
            getOptionLabel={(option) => option.name}
            onChange={handleChange}
            value={[]}
            filterSelectedOptions
            renderInput={(params) => (
              <TextField
                {...params}
                variant="outlined"
                label="Variable Sources"
                placeholder="Add source"
                multiline
              />
            )}
          />
        </div>
      )
    } else {
      return (
        <div>
          <Autocomplete
            multiple
            id="tags-outlined"
            options={Object.values(sourceOptions)}
            getOptionLabel={(option) => option.name}
            onChange={handleChange}
            value={sources}
            getOptionSelected={(option, value) => (
              option.id === value.id
            )}
            filterSelectedOptions
            renderInput={(params) => (
              <TextField
                {...params}
                variant="outlined"
                label="Sources"
                placeholder="Add source"
              />
            )}
          />
        </div>
      )
    }
  }

  const SourcesList = (props) => {
    const { sources, datasetId, variable } = props

    let { sourceOptions } = props

    if (get(variable.topic, 'id') !== 0 && (!isEmpty(variable.topic) || !isEmpty(variable.sources_topic)) ){
      sourceOptions = sourceOptions.filter(opt => {
        return (
          get(opt.topic, 'id') == get(variable.topic, 'id') ||
          get(opt.resolved_topic, 'id') == get(variable.topic, 'id') ||
          (get(opt.topic, 'id') === 0 && get(opt.resolved_topic, 'id') === 0) || (opt.topic === null && opt.resolved_topic === null)
        )
      })
    }

    const variableId = variable.id
    const dispatch = useDispatch()

    const handleAddSource = (newSources) => {
      dispatch(DatasetVariable.add_source(datasetId, variableId, newSources));
    }

    const handleRemoveSource = (oldSources) => {
      oldSources.map((source)=>{
        dispatch(DatasetVariable.remove_source(datasetId, variableId, source));
      })
    }

    var difference = []

    const handleChange = (event, value, reason) => {
      switch (reason) {
        case 'select-option':
          difference = value.filter(x => !sources.includes(x));
          if(!isEmpty(difference)){
            return handleAddSource(difference.map((source) => { return source.label }))
          };
          break;
        case 'remove-option':
          difference = sources.filter(x => !value.includes(x));
          if(!isEmpty(difference)){
            return handleRemoveSource(difference)
          };
          break;
        default:
          return null;
      }
    }

    if(isEmpty(sources)){
      return (
        <div>
           <Autocomplete
            multiple
            id="tags-outlined"
            options={Object.values(sourceOptions)}
            getOptionLabel={(option) => option.label}
            onChange={handleChange}
            value={[]}
            filterSelectedOptions
            renderInput={(params) => (
              <TextField
                {...params}
                variant="outlined"
                label="Sources"
                placeholder="Add source"
                multiline
              />
            )}
          />
        </div>
      )
    }else{
      return (
        <div>
           <Autocomplete
            multiple
            id="tags-outlined"
            options={Object.values(sourceOptions)}
            getOptionLabel={(option) => option.label || option.name }
            onChange={handleChange}
            value={sources}
            getOptionSelected= {(option, value) => (
              option.id === value.id
            )}
            filterSelectedOptions
            renderInput={(params) => (
              <TextField
                {...params}
                variant="outlined"
                label="Sources"
                placeholder="Add source"
              />
            )}
          />
        </div>
      )
    }
  }

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Datasets'}>
        <DatasetHeading dataset={dataset} mode={'view'} />
      {!dataLoaded
        ? <Loader />
        : (
          <>
            <span style={{ margin: 16 }}/>
            <SearchBar
              placeholder={`Search by name, label, source or topic (press return to perform search)`}
              onRequestSearch={(newValue) =>
                      setSearch(newValue)
                    }
              onCancelSearch={() => {
                      setSearch('')
                    }}
            />
            <Divider style={{ margin: 16 }} variant="middle" />
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell>ID</TableCell>
                  <TableCell>Name</TableCell>
                  <TableCell>Label</TableCell>
                  <TableCell>Type</TableCell>
                  <TableCell>Used by</TableCell>
                  <TableCell style={{ width: 500 }}>Sources</TableCell>
                  <TableCell style={{ width: 500 }}>Topic</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {rows.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map((row) => {
                  const key =  'DatasetVariable:' + row.id
                  const status = get(statuses, key, {})

                  var errorMessage = null;

                  if(status.error){
                    errorMessage = status.errorMessage
                  }else if(row.errors){
                    errorMessage = row.errors
                  }

                  return (
                  <>
                  { !isEmpty(errorMessage) && (
                    <TableRow>
                      <TableCell colSpan={7} style={{ border: '0'}}>
                        <Alert severity="error">
                          <AlertTitle>Error</AlertTitle>
                          {errorMessage}
                        </Alert>
                      </TableCell>
                    </TableRow>
                  )}
                  <VariableTableRow row={row} />
                  </>
                  )
                })}
              </TableBody>
             <TableFooter>
                <TableRow>
                  <TablePagination
                    rowsPerPageOptions={[20, 50, 100, { label: 'All', value: -1 }]}
                    colSpan={3}
                    count={rows.length}
                    rowsPerPage={rowsPerPage}
                    page={page}
                    onChangePage={handleChangePage}
                    onChangeRowsPerPage={handleChangeRowsPerPage}
                    SelectProps={{
                      inputProps: { 'aria-label': 'rows per page' },
                      native: true,
                    }}
                  />
                </TableRow>
              </TableFooter>
            </Table>
          </>
        )}
      </Dashboard>
    </div>
  );
}

export default DatasetView;

import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Dataset, DatasetVariable, Topics } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { Loader } from '../components/Loader'
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import TableFooter from '@material-ui/core/TableFooter';
import TablePagination from '@material-ui/core/TablePagination';
import Button from '@material-ui/core/Button';
import Autocomplete from '@material-ui/lab/Autocomplete';
import TextField from '@material-ui/core/TextField';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
import { get, isEmpty, isNil } from 'lodash'
import { makeStyles } from '@material-ui/core/styles';
import FormControl from '@material-ui/core/FormControl';
import InputLabel from '@material-ui/core/InputLabel';
import Select from '@material-ui/core/Select';
import { Alert, AlertTitle } from '@material-ui/lab';

const TopicList = (props) => {
  const {topicId, datasetId, variableId} = props

  const dispatch = useDispatch()

  const topics = useSelector(state => state.topics);

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
    dispatch(DatasetVariable.topic.set(datasetId, variableId, event.target.value));
  }

  if(isEmpty(topics)){
    return 'Fetching topics'
  }else if(isNil(topicId)){
    return (
          <div>
            <FormControl className={classes.formControl}>
              <InputLabel htmlFor="grouped-native-select">Topic</InputLabel>
              <Select native id="grouped-native-select" onChange={handleChange}>
                <option aria-label="None" value="" />
                {Object.values(topics).map((topic) => (
                  <option key={topic.id} value={topic.id}>{(topic.level === 1) ? topic.name : '--' + topic.name }</option>
                ))}
              </Select>
            </FormControl>
          </div>
    )
  }else{
    return (
          <div>
            <FormControl className={classes.formControl}>
              <InputLabel htmlFor="grouped-native-select">Topic</InputLabel>
              <Select native defaultValue={topicId} id="grouped-native-select" onChange={handleChange}>
                <option aria-label="None" value="" />
                {Object.values(topics).map((topic) => (
                  <option key={topic.id} value={topic.id}>{(topic.level === 1) ? topic.name : '--' + topic.name }</option>
                ))}
              </Select>
            </FormControl>
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

  const rows: RowsProp = Object.values(variables);

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

  const SourcesList = (props) => {
    const { sources, datasetId, variable } = props
    let { sourceOptions } = props
    sourceOptions = sourceOptions.filter(opt => get(opt.topic, 'id') == get(variable.topic, 'id'))
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
            getOptionLabel={(option) => option.label}
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
      {!dataLoaded
        ? <Loader />
        : (
          <Table size="small">
            <TableHead>
              <TableRow>
                <TableCell>ID</TableCell>
                <TableCell>Name</TableCell>
                <TableCell>Label</TableCell>
                <TableCell>Type</TableCell>
                <TableCell>Used by</TableCell>
                <TableCell>Sources</TableCell>
                <TableCell>Topic</TableCell>
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
                <TableRow key={row.id}>
                  <TableCell>{row.id}</TableCell>
                  <TableCell>{row.name}</TableCell>
                  <TableCell>{row.label}</TableCell>
                  <TableCell>{row.var_type}</TableCell>
                  <TableCell></TableCell>
                  <TableCell><SourcesList sources={row.sources} sourceOptions={get(dataset,'questions',[])} datasetId={datasetId} variable={row} /></TableCell>
                  <TableCell>
                    <TopicList topicId={get(row.topic, 'id')} datasetId={datasetId} variableId={row.id} />
                    {!isNil(row.sources_topic) && (
                      <em>Resolved topic from sources - { get(row.sources_topic,'name') }</em>
                    )}
                  </TableCell>
                </TableRow>
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
        )}
      </Dashboard>
    </div>
  );
}

export default DatasetView;

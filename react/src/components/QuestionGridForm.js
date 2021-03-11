import React, { useEffect } from 'react';
import { get, isNil } from "lodash";
import { Form, Field } from 'react-final-form';
import { useDispatch, useSelector } from 'react-redux'
import { QuestionGrids, ResponseDomainNumerics, ResponseDomainTexts, ResponseDomainDatetimes, ResponseDomainCodes } from '../actions'
import { ObjectStatusBar } from '../components/ObjectStatusBar'
import { DeleteObjectButton } from '../components/DeleteObjectButton'
import { ObjectCheckForInitialValues } from '../support/ObjectCheckForInitialValues'
import arrayMutators from 'final-form-arrays'
import { FieldArray } from 'react-final-form-arrays'
import { OnChange } from 'react-final-form-listeners'
import { makeStyles } from '@material-ui/core/styles';

import {
  TextField,
  Select
} from 'mui-rff';
import {
  Paper,
  Grid,
  Button,
  CssBaseline,
  MenuItem,
  Table,
  TableContainer,
  TableBody,
  TableHead,
  TableRow,
  TableCell
} from '@material-ui/core';
import {
  Autocomplete
} from '@material-ui/lab';
import DeleteIcon from '@material-ui/icons/Delete';


const useStyles = makeStyles({
  table: {
    minWidth: 650,
  },
});

const validate = values => {
  const errors = {};
   if (!values.label) {
     errors.label = 'Required';
   }
  return errors;
};

const formFields = [
  {
    size: 12,
    field: (
      <TextField
        label="Label"
        name="label"
        margin="none"
        required={true}
      />
    ),
  },
  {
    size: 12,
    field: (
      <TextField
        label="Instruction"
        name="instruction"
        margin="none"
      />
    ),
  },
  {
    size: 12,
    field: (
      <TextField
        label="Literal"
        name="literal"
        margin="none"
        required={true}
      />
    ),
  },
  {
    type: 'select',
    size: 12,
    field: (options) => (
      <Select
        name="horizontal_code_list_id"
        label="Horizontal Code List (X)"
        formControlProps={{ margin: 'none' }}
      >
        <MenuItem></MenuItem>
        {options.map((item, idx) => (
          <MenuItem value={item.id}>{item.label}</MenuItem>
        ))}
      </Select>
    ),
  },
  {
      type: 'select',
      size: 12,
      field: (options) => (
        <Select
          name="vertical_code_list_id"
          label="Vertical Code List (Y)"
          formControlProps={{ margin: 'none' }}
        >
          <MenuItem></MenuItem>
          {options.map((item, idx) => (
            <MenuItem value={item.id}>{item.label}</MenuItem>
          ))}
        </Select>
      )
  },
  {
      type: 'select',
      size: 12,
      field: (options) => (
        <Select
          name="corner_label"
          label="Corner Label"
          formControlProps={{ margin: 'none' }}
        >
          <MenuItem></MenuItem>
          <MenuItem value='H'>Horizontal</MenuItem>
          <MenuItem value='V'>Vertical</MenuItem>
        </Select>
      )
  },
  {
    size: 12,
    field: (
      <TextField
        label="Roster Label"
        name="roster_label"
        margin="none"
      />
    ),
  },
  {
    size: 12,
    field: (
      <TextField
        label="Roster Row Number"
        name="roster_rows"
        margin="none"
      />
    ),
  }
];

export const QuestionGridForm = (props) => {
  const {questionGrid, instrumentId} = props;

  var codeLists = useSelector(state => get(state.codeLists, instrumentId, {}));

  // Only show response domains in the list of codeLists
  codeLists = Object.values(codeLists).filter((cl) => { return cl.rd === false})

  const dispatch = useDispatch();
  const classes = useStyles();

  const onSubmit = (values) => {
    values = ObjectCheckForInitialValues(questionGrid, values)

    if(isNil(questionGrid.id)){
      dispatch(QuestionGrids.create(instrumentId, values))
    }else{
      dispatch(QuestionGrids.update(instrumentId, questionGrid.id, values))
    }
  }

  const responseDomainCodes = useSelector(state => get(state.responseDomainCodes, instrumentId, {}));
  const responseDomainNumerics = useSelector(state => get(state.responseDomainNumerics, instrumentId, {}));
  const responseDomainTexts = useSelector(state => get(state.responseDomainTexts, instrumentId, {}));
  const responseDomainDatetimes = useSelector(state => get(state.responseDomainDatetimes, instrumentId, {}));

  const responseDomains = [...Object.values(responseDomainCodes), ...Object.values(responseDomainNumerics), ...Object.values(responseDomainTexts), ...Object.values(responseDomainDatetimes)]

  useEffect(() => {
    dispatch(ResponseDomainCodes.all(instrumentId));
    dispatch(ResponseDomainNumerics.all(instrumentId));
    dispatch(ResponseDomainTexts.all(instrumentId));
    dispatch(ResponseDomainDatetimes.all(instrumentId));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  console.log(questionGrid)
  return (
    <div style={{ padding: 16, margin: 'auto', maxWidth: 1000 }}>
      <ObjectStatusBar id={questionGrid.id || 'new'} type={'QuestionGrid'} />
      <CssBaseline />
      <Form
        onSubmit={onSubmit}
        initialValues={questionGrid}
        validate={validate}
        mutators={{
          ...arrayMutators
        }}
        render={({
        handleSubmit,
        form: {
          mutators: { push, pop }
        }, // injected from final-form-arrays above
        pristine,
        form,
        submitting,
        values
      }) => (
          <form onSubmit={handleSubmit} noValidate>
            <Paper style={{ padding: 16 }}>
              <Grid container alignItems="flex-start" spacing={2}>
                {formFields.map((item, idx) => (
                  <Grid item xs={item.size} key={idx}>
                    {item.type && item.type === 'select'
                      ? item.field(codeLists)
                      : item.field
                    }
                  </Grid>
                ))}
                <OnChange name="horizontal_code_list_id">
                  {(value, previous) => {
                    const codeList = codeLists.find(el => el.id === value)
                    if(codeList){
                      values.cols = codeList.codes.map((code) => {
                        return {
                          label: code.label,
                          value: code.value,
                          order: code.order
                        }
                      })
                    }
                  }}
                </OnChange>
                <h3>Response Domains</h3>
                <TableContainer component={Paper}>
                    <Table className={classes.table} aria-label="simple table">
                      <TableHead>
                        <TableRow>
                          <TableCell>Column</TableCell>
                          <TableCell>Type and Label</TableCell>
                          <TableCell>Actions</TableCell>
                        </TableRow>
                      </TableHead>
                      <TableBody>
                        <FieldArray name="cols">
                          {({ fields }) =>
                            fields.map((name, index) => (
                              <TableRow key={name}>
                                <TableCell>{fields.value[index].label}</TableCell>
                                <TableCell>
                                 <Autocomplete
                                  autoComplete
                                  options={Object.values(responseDomains)}
                                  getOptionLabel={(option) => (option.type === '') ? `` :`${option.label} - ${option.type}`}
                                  onChange={(event, value, reason)=>{
                                    var rd;
                                    if(isNil(value)){
                                      rd = {...fields.value[index].rd, ...{type: '', id: null, label: ''} }
                                    }else{
                                      rd = {...fields.value[index].rd, ...{type: value.type, id: value.id, label: value.label} }
                                    }
                                    fields.update(index, {...fields.value[index], ...{rd: rd} })
                                  } }
                                  value={(fields.value[index].rd) ? {type: fields.value[index].rd.type, id: fields.value[index].rd.id, label:fields.value[index].rd.label} : {type: '', id: null, label: ''}}
                                  getOptionSelected= {(option, value) => {
                                    console.log(fields)
                                    return (
                                    (option.type === value.type && option.id === value.id)
                                  )}}
                                  renderInput={(params) => (
                                    <TextField name={`${name}.type - ${name}.label`}
                                      {...params}
                                      variant="outlined"
                                      label="Label"
                                      placeholder="label"
                                    />
                                  )}
                                />
                                </TableCell>
                                <TableCell>
                                  <span
                                    onClick={() => fields.update(index, {...fields.value[index], ...{rd: {type: '', id: null, label: ''} } }) }
                                    style={{ cursor: 'pointer' }}
                                  >
                                    <DeleteIcon />
                                  </span>
                                </TableCell>
                              </TableRow>
                            ))
                          }
                        </FieldArray>
                    </TableBody>
                  </Table>
                </TableContainer>
                <Grid item style={{ marginTop: 16 }}>
                  <Button
                    type="button"
                    variant="contained"
                    onClick={form.reset}
                    disabled={submitting || pristine}
                  >
                    Reset
                  </Button>
                </Grid>
                <Grid item style={{ marginTop: 16 }}>
                  <Button
                    variant="contained"
                    color="primary"
                    type="submit"
                    disabled={submitting}
                  >
                    Submit
                  </Button>
                </Grid>
                <DeleteObjectButton id={values.id} instrumentId={instrumentId} action={QuestionGrids} />
              </Grid>
            </Paper>
          </form>
        )}
      />
    </div>
  );
}

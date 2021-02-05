import React, { useEffect } from 'react';
import { get, isNil } from "lodash";
import { Form } from 'react-final-form';
import { useDispatch, useSelector } from 'react-redux'
import { QuestionItems, ResponseDomainNumerics, ResponseDomainTexts, ResponseDomainDatetimes } from '../actions'
import { ObjectStatusBar } from '../components/ObjectStatusBar'
import { DeleteObjectButton } from '../components/DeleteObjectButton'
import { ObjectCheckForInitialValues } from '../support/ObjectCheckForInitialValues'
import arrayMutators from 'final-form-arrays'
import { FieldArray } from 'react-final-form-arrays'
import { makeStyles } from '@material-ui/core/styles';

import {
  TextField,
} from 'mui-rff';
import {
  Paper,
  Grid,
  Button,
  CssBaseline,
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
import AddCircleOutlineIcon from '@material-ui/icons/AddCircleOutline';



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
  }
];

export const QuestionItemForm = (props) => {
  const {questionItem, instrumentId} = props;

  const categories = useSelector(state => get(state.categories, instrumentId, {}));

  const dispatch = useDispatch();
  const classes = useStyles();

  const responseDomainNumerics = useSelector(state => get(state.responseDomainNumerics, instrumentId, {}));
  const responseDomainTexts = useSelector(state => get(state.responseDomainTexts, instrumentId, {}));
  const responseDomainDatetimes = useSelector(state => get(state.responseDomainDatetimes, instrumentId, {}));

  const responseDomains = [...Object.values(responseDomainNumerics), ...Object.values(responseDomainTexts), ...Object.values(responseDomainDatetimes)]

  const onSubmit = (values) => {
    values = ObjectCheckForInitialValues(questionItem, values)

    if(isNil(questionItem.id)){
      dispatch(QuestionItems.create(instrumentId, values))
    }else{
      dispatch(QuestionItems.update(instrumentId, questionItem.id, values))
    }
  }

  useEffect(() => {
    dispatch(ResponseDomainNumerics.all(instrumentId));
    dispatch(ResponseDomainTexts.all(instrumentId));
    dispatch(ResponseDomainDatetimes.all(instrumentId));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  return (
    <div style={{ padding: 16, margin: 'auto', maxWidth: 1000 }}>
      <ObjectStatusBar id={questionItem.id || 'new'} type={'QuestionItem'} />
      <CssBaseline />
      <Form
        onSubmit={onSubmit}
        initialValues={questionItem}
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
                    {item.field}
                  </Grid>
                ))}
                <h3>Response Domains</h3>
                <AddCircleOutlineIcon onClick={() => push('rds', {})}/>
                <TableContainer component={Paper}>
                    <Table className={classes.table} aria-label="simple table">
                      <TableHead>
                        <TableRow>
                          <TableCell>Type and Label</TableCell>
                          <TableCell>Actions</TableCell>
                        </TableRow>
                      </TableHead>
                      <TableBody>
                        <FieldArray name="rds">
                          {({ fields }) =>
                            fields.map((name, index) => (
                              <TableRow key={name}>
                                <TableCell>
                                 <Autocomplete
                                  freesolo="true"
                                  options={Object.values(responseDomains)}
                                  getOptionLabel={(option) => `${option.type} - ${option.label}`}
                                  onChange={(event, value, reason)=>{
                                    if(isNil(value)){
                                      fields.update(index, {...fields.value[index], ...{type: null, id: null, label: null} })
                                    }else{
                                      fields.update(index, {...fields.value[index], ...{type: value.type, id: value.id, label: value.label} })
                                    }
                                  } }
                                  value={{type: fields.value[index].type, id: fields.value[index].id, label:fields.value[index].label}}
                                  getOptionSelected= {(option, value) => (
                                    option.type === value.type && option.id === value.id
                                  )}
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
                                    onClick={() => fields.remove(index)}
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
                <DeleteObjectButton id={values.id} instrumentId={instrumentId} action={QuestionItems} />
              </Grid>
            </Paper>
          </form>
        )}
      />
    </div>
  );
}

import React from 'react';
import { get, isNil } from "lodash";
import { Form, Field } from 'react-final-form';
import { useDispatch, useSelector } from 'react-redux'
import { ResponseDomainDatetimes } from '../actions'
import { ObjectStatusBar } from '../components/ObjectStatusBar'
import { DeleteObjectButton } from '../components/DeleteObjectButton'
import { ObjectCheckForInitialValues } from '../support/ObjectCheckForInitialValues'
import arrayMutators from 'final-form-arrays'
import { FieldArray } from 'react-final-form-arrays'
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
  MenuItem
} from '@material-ui/core';


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
   if (!values.subtype) {
     errors.subtype = 'Required';
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
    type: 'select',
    size: 12,
    field: (options) => (
      <Select
        name="subtype"
        label="Type"
        formControlProps={{ margin: 'none' }}
        required={true}
      >
        <MenuItem value="Date">Date</MenuItem>
        <MenuItem value="Time">Time</MenuItem>
        <MenuItem value="Duration">Duration</MenuItem>
      </Select>
    ),
  },
  {
    size: 12,
    visible: (values) => {
      return get(values, 'subtype', '') === 'Duration'
    },
    field: (
      <TextField
        label="Format"
        name="format"
        margin="none"
      />
    ),
  }
];

const FormField = (props) => {
  const {item, values} = props

  if(item.visible !== undefined && !item.visible(values) ){
    return ''
  }

  if(item.type && item.type === 'select'){
    return item.field()
  }else{
    return item.field
  }
}

export const ResponseDomainDatetimeForm = (props) => {
  const {responseDomain, instrumentId} = props;

  const dispatch = useDispatch();
  const classes = useStyles();

  const onSubmit = (values) => {
    values = ObjectCheckForInitialValues(responseDomain, values)

    if(isNil(responseDomain.id)){
      dispatch(ResponseDomainDatetimes.create(instrumentId, values))
    }else{
      dispatch(ResponseDomainDatetimes.update(instrumentId, responseDomain.id, values))
    }
  }

  return (
    <div style={{ padding: 16, margin: 'auto', maxWidth: 1000 }}>
      <ObjectStatusBar id={responseDomain.id || 'new'} type={'ResponseDomain'} />
      <CssBaseline />
      <Form
        onSubmit={onSubmit}
        initialValues={responseDomain}
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
                    <FormField item={item} values={values} />
                  </Grid>
                ))}
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
                <DeleteObjectButton id={values.id} instrumentId={instrumentId} action={ResponseDomainDatetimes} />
              </Grid>
            </Paper>
          </form>
        )}
      />
    </div>
  );
}

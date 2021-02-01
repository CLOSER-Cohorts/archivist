import React from 'react';
import { get, isNil } from "lodash";
import { Form } from 'react-final-form';
import { useDispatch, useSelector } from 'react-redux'
import { CcLoops } from '../actions'
import { ObjectStatusBar, ObjectStatus } from '../components/ObjectStatusBar'
import { DeleteObjectButton } from '../components/DeleteObjectButton'
import { ObjectCheckForInitialValues } from '../support/ObjectCheckForInitialValues'
import arrayMutators from 'final-form-arrays'
import { FieldArray } from 'react-final-form-arrays'
import { makeStyles } from '@material-ui/core/styles';
import { ObjectColour } from '../support/ObjectColour'

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
  paper:{
    boxShadow :`5px 5px 15px 5px  #${ObjectColour('loop')}`
  }
});

const validate = (values, status) => {

  const errors = {};

  if(status.errors){
    Object.keys(status.errors).map((key)=>{
      if(isNil(values[key]) || values[key] == ''){
        errors[key] = status.errors[key][0];
      }
    })
  }else{
   if (!values.label) {
     errors.label = 'Required';
   }
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
        label="Variable"
        name="loop_var"
        margin="none"
        required={true}
      />
    ),
  },
  {
    size: 12,
    field: (
      <TextField
        label="Start Value"
        name="start_val"
        margin="none"
        required={true}
      />
    ),
  },
  {
    size: 12,
    field: (
      <TextField
        label="End Value"
        name="end_val"
        margin="none"
      />
    ),
  },
  {
    size: 12,
    field: (
      <TextField
        label="Loop While"
        name="loop_while"
        margin="none"
        required={true}
      />
    ),
  }
];

export const CcLoopForm = (props) => {
  const {ccLoop, instrumentId, onChange, path, onDelete} = props;

  const dispatch = useDispatch();
  const classes = useStyles();

  const status = ObjectStatus(ccLoop.id || 'new', 'CcLoop')

  const onSubmit = (values) => {
    values = ObjectCheckForInitialValues(ccLoop, values)

    if(isNil(ccLoop.id)){
      dispatch(CcLoops.create(instrumentId, values, (newObject) => {
        onChange({node: { ...values, ...newObject  }, path: path})
      }))
    }else{
      dispatch(CcLoops.update(instrumentId, ccLoop.id, values))
      onChange({node: values, path: path})
    }
  }

  return (
    <div style={{ padding: 16, margin: 'auto', maxWidth: 1000 }}>
      <ObjectStatusBar id={ccLoop.id || 'new'} type={'CcLoop'} />
      <CssBaseline />
      <Form
        onSubmit={onSubmit}
        initialValues={ccLoop}
        validate={(values) => validate(values, status)}
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
            <Paper style={{ padding: 16 }} className={classes.paper}>
              <Grid container alignItems="flex-start" spacing={2}>
                {formFields.map((item, idx) => (
                  <Grid item xs={item.size} key={idx}>
                    {item.type && item.type === 'select'
                      ? item.field([])
                      : item.field
                    }
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
                <DeleteObjectButton id={values.id} instrumentId={instrumentId} action={CcLoops} onDelete={()=> { onDelete({ path }) }}/>
              </Grid>
            </Paper>
          </form>
        )}
      />
    </div>
  );
}

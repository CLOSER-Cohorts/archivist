import React from 'react';
import { isNil } from "lodash";
import { Form } from 'react-final-form';
import { useDispatch } from 'react-redux'
import { Dataset } from '../actions'
import { ObjectStatusBar, ObjectStatus } from '../components/ObjectStatusBar'
import { ObjectCheckForInitialValues } from '../support/ObjectCheckForInitialValues'
import { makeStyles } from '@material-ui/core/styles';
import { ObjectColour } from '../support/ObjectColour'

import {
  TextField
} from 'mui-rff';
import {
  Paper,
  Grid,
  Button,
  CssBaseline
} from '@material-ui/core';


const useStyles = makeStyles({
  table: {
    minWidth: 650,
  },
  paper:{
    boxShadow :`5px 5px 15px 5px  #${ObjectColour('statement')}`
  }
});

const validate = (values, status) => {

  const errors = {};

  if(status.errors){
    Object.keys(status.errors).map((key)=>{
      if(isNil(values[key]) || values[key] === ''){
        errors[key] = status.errors[key][0];
        return
      }
    })
  }else{
   if (!values.name) {
     errors.name = 'Required';
   }
  }

  return errors;
};

const formFields = [
  {
    size: 12,
    field: (
      <TextField
        label="Study"
        name="study"
        margin="none"
        required={false}
        multiline
      />
    ),
  },
  {
    size: 12,
    field: (
      <TextField
        label="Dataset Title"
        name="name"
        margin="none"
        required={false}
        multiline
      />
    ),
  },
  {
    size: 12,
    field: (
      <TextField
        label="DOI"
        name="doi"
        margin="none"
        required={false}
        multiline
      />
    ),
  }
];

export const DatasetForm = (props) => {
  const {dataset, onChange, path, onDelete} = props;

  const dispatch = useDispatch();
  const classes = useStyles();

  const status = ObjectStatus(dataset.id || 'new', 'Dataset')

  const onSubmit = (values) => {
    values = ObjectCheckForInitialValues(dataset, values)
    if(!isNil(dataset.id)){
      dispatch(Dataset.update(dataset.id, values))
    }
  }

  return (
    <div style={{ padding: 16, margin: 'auto', maxWidth: 1000 }}>
      <ObjectStatusBar id={dataset.id || 'new'} type={'Dataset'} />
      <CssBaseline />
      <Form
        onSubmit={onSubmit}
        initialValues={dataset}
        validate={(values) => validate(values, status)}
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
              </Grid>
            </Paper>
          </form>
        )}
      />
    </div>
  );
}

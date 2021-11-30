import React from 'react';
import { isNil } from "lodash";
import { Form } from 'react-final-form';
import { useDispatch } from 'react-redux'
import { Instrument } from '../actions'
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
  CssBaseline,
  FormControlLabel,
  Switch,
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
   if (!values.label) {
     errors.label = 'Required';
   }
  }

  return errors;
};

const formFields = (item, signedOff, setSignedOff) => {
  return [
    {
      size: 12,
      field: (
        <TextField
          label="Prefix"
          name="prefix"
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
          label="Instrument Title"
          name="label"
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
          label="Agency"
          name="agency"
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
          label="Version"
          name="version"
          margin="none"
          required={false}
          multiline
        />
      ),
    },
    {
      size: 12,
      field: (
        <FormControlLabel
          control={
            <Switch
              name="signed_off"
              checked={signedOff}
              onChange={(e)=>{setSignedOff(e.target.checked)}}
              color="primary"
            />
          }
          label="Signed Off"
        />
      ),
    },
  ]
}

export const AdminInstrumentForm = (props) => {
  const {instrument} = props;

  const [signedOff, setSignedOff] = React.useState(instrument.signed_off);

  const dispatch = useDispatch();
  const classes = useStyles();

  const status = ObjectStatus(instrument.id || 'new', 'Instrument')

  const onSubmit = (values) => {
    values.signed_off = signedOff

    values = ObjectCheckForInitialValues(instrument, values)
    if(isNil(instrument.id)){
      dispatch(Instrument.create(values))
    }else{
      dispatch(Instrument.update(instrument.id, values))
    }
  }

  return (
    <div style={{ padding: 16, margin: 'auto', maxWidth: 1000 }}>
      <ObjectStatusBar id={instrument.id || 'new'} type={'Instrument'} />
      <CssBaseline />
      <Form
        onSubmit={onSubmit}
        initialValues={instrument}
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
                {formFields(instrument, signedOff, setSignedOff).map((item, idx) => (
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

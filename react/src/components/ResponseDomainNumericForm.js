import React from 'react';
import { get, isNil } from "lodash";
import { Form } from 'react-final-form';
import { useDispatch, useSelector } from 'react-redux'
import { ResponseDomainNumerics } from '../actions'
import { ObjectStatusBar } from '../components/ObjectStatusBar'
import { DeleteObjectButton } from '../components/DeleteObjectButton'
import { UsedByQuestions } from '../components/UsedByQuestions'
import { ObjectCheckForInitialValues } from '../support/ObjectCheckForInitialValues'
import arrayMutators from 'final-form-arrays'

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
          <MenuItem></MenuItem>
          <MenuItem value='Integer'>Integer</MenuItem>
          <MenuItem value='Float'>Float</MenuItem>
        </Select>
      )
  },
  {
    size: 12,
    field: (
      <TextField
        label="Min"
        name="min"
        margin="none"
      />
    ),
  },
  {
    size: 12,
    field: (
      <TextField
        label="Max"
        name="max"
        margin="none"
      />
    ),
  }
];

export const ResponseDomainNumericForm = (props) => {
  const {responseDomain, instrumentId, instrument} = props;

  const codeLists = useSelector(state => get(state.codeLists, instrumentId, {}));

  const dispatch = useDispatch();

  const onSubmit = (values) => {
    values = ObjectCheckForInitialValues(responseDomain, values)

    if(isNil(responseDomain.id)){
      dispatch(ResponseDomainNumerics.create(instrumentId, values))
    }else{
      dispatch(ResponseDomainNumerics.update(instrumentId, responseDomain.id, values))
    }
  }

  return (
    <div style={{ padding: 0 }}>
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
                    {item.type && item.type === 'select'
                      ? item.field(codeLists)
                      : item.field
                    }
                  </Grid>
                ))}
                {instrument && !instrument.signed_off && (
                  <>
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
                        Save
                      </Button>
                    </Grid>
                    <DeleteObjectButton id={values.id} instrumentId={instrumentId} action={ResponseDomainNumerics} />
                  </>
                )}
              </Grid>
              <UsedByQuestions item={responseDomain} instrumentId={instrumentId} />
            </Paper>
          </form>
        )}
      />
    </div>
  );
}

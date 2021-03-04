import React from 'react';
import { Form, Field } from 'react-final-form';
import { useDispatch } from 'react-redux'
import { AdminDataset } from '../actions'
import { ObjectStatusBar, ObjectStatus } from '../components/ObjectStatusBar'
import { FileField } from '../components/FileField'
import { makeStyles } from '@material-ui/core/styles';
import { ObjectColour } from '../support/ObjectColour'

import {
  Paper,
  Grid,
  Button,
  CssBaseline,
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

  return errors;
};

const formFields = [
  {
    size: 12,
    field: (
      <FileField name="files" />
    ),
  }
];

export const AdminImportMappingsForm = ({type, hint, onSubmit=()=>{}}) => {

  const dispatch = useDispatch();
  const classes = useStyles();

  const status = ObjectStatus('new', 'AdminImportMapping')

  return (
    <div style={{ padding: 16, margin: 'auto', maxWidth: 1000 }}>
      <h2>Import Mappings</h2>
      <ObjectStatusBar type={'AdminImportMapping'} id={'new'} />
      <CssBaseline />
      <Form
        onSubmit={onSubmit}
        initialValues={{files: []}}
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
                  {hint}
                  <Button
                    variant="contained"
                    color="primary"
                    type="submit"
                    disabled={submitting}
                  >
                    Import {type}
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

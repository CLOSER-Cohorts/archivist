import React from 'react';
import { get, isNil } from "lodash";
import { Form, Field } from 'react-final-form';
import { useDispatch, useSelector } from 'react-redux'
import { QuestionGrids } from '../actions'
import { ObjectStatusBar } from '../components/ObjectStatusBar'
import { DeleteObjectButton } from '../components/DeleteObjectButton'
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
  codeLists = Object.values(codeLists).filter((cl) => { return cl.rd === true})

  const dispatch = useDispatch();
  const classes = useStyles();

  const onSubmit = (values) => {
    if(isNil(questionGrid.id)){
      dispatch(QuestionGrids.create(instrumentId, values))
    }else{
      dispatch(QuestionGrids.update(instrumentId, questionGrid.id, values))
    }
  }

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

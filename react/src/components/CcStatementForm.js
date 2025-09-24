import React from 'react';
import { get, isNil } from "lodash";
import { Form, Field } from 'react-final-form';
import { useDispatch, useSelector } from 'react-redux'
import { CcStatements } from '../actions'
import { ObjectStatusBar, ObjectStatus } from '../components/ObjectStatusBar'
import { DeleteObjectButton } from '../components/DeleteObjectButton'
import { ObjectCheckForInitialValues } from '../support/ObjectCheckForInitialValues'
import arrayMutators from 'final-form-arrays'
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

const validate = (values) => {
  const errors = {};

  if (!values.label) {
    errors.label = 'Required';
  }

  return errors;
};

const formFields= (labelArray) => [
  {
    size: 12,
    field: (
      <Field name="label">
        {({ input, meta }) => {
          const [matches, setMatches] = React.useState([]);
          React.useEffect(() => {
            const foundMatches = labelArray.filter(label => 
              label.startsWith(input.value) && input.value !== '' && label !== meta.initial
            );
            setMatches(foundMatches);
          }, [input.value, labelArray]);

          return (
            <div>
              <TextField
                {...input}
                label="Label"
                margin="none"
                required={true}
                multiline
                helperText={
                  matches.length > 0
                    ? `Found similar labels: ${matches.join(', ')}`
                    : "Enter a unique label"
                }
              />
              {matches.length > 0 && (
                <ul style={{ margin: '8px 0', paddingLeft: '16px', color: 'red', fontSize: '0.9em' }}>
                  {matches.map((match, index) => (
                    <li key={index}>{match}</li>
                  ))}
                </ul>
              )}
            </div>
          );
        }}
      </Field>
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
        multiline
      />
    ),
  },
];

export const CcStatementForm = (props) => {
  const {ccStatement, instrumentId, onChange, path, onDelete, onCreate} = props;

  const dispatch = useDispatch();
  const classes = useStyles();

  const statements = useSelector(state => state.cc_statements);
  const cc_statements = get(statements, instrumentId, {});
  const labelArray = Object.values(cc_statements).map(statement => statement.label);  

  const status = ObjectStatus(ccStatement.id || 'new', 'CcStatement')

  const onSubmit = (values) => {
    values = ObjectCheckForInitialValues(ccStatement, values)

    if(isNil(ccStatement.id)){
      dispatch(CcStatements.create(instrumentId, values, (newObject) => {
        onChange({node: { ...values, ...newObject  }, path: path})
        onCreate()
      }))
    }else{
      dispatch(CcStatements.update(instrumentId, ccStatement.id, values, (updatedObject) => {
        onChange({ node: values, path: path })
      }))
    }
  }

  return (
    <div style={{ padding: 16, margin: 'auto', maxWidth: 1000 }}>
      <ObjectStatusBar id={ccStatement.id || 'new'} type={'CcStatement'} />
      <CssBaseline />
      <Form
        onSubmit={onSubmit}
        initialValues={ccStatement}
        validate={(values) => validate(values)}
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
                {formFields(labelArray).map((item, idx) => (
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
                <DeleteObjectButton id={values.id} instrumentId={instrumentId} action={CcStatements} onDelete={()=> { onDelete({ path }) }} />
              </Grid>
            </Paper>
          </form>
        )}
      />
    </div>
  );
}

import React, { useState } from 'react';
import { get, isNil } from "lodash";
import { Form } from 'react-final-form';
import { useDispatch, useSelector } from 'react-redux'
import { CcQuestions } from '../actions'
import { ObjectStatusBar } from '../components/ObjectStatusBar'
import { DeleteObjectButton } from '../components/DeleteObjectButton'
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
      type: 'select',
      size: 12,
      field: (options) => (
        <Select
          name="question_type"
          label="Type"
          formControlProps={{ margin: 'none' }}
        >
          <MenuItem></MenuItem>
          <MenuItem value='QuestionItem'>Item</MenuItem>
          <MenuItem value='QuestionGrid'>Grid</MenuItem>
        </Select>
      )
  }
];

export const CcQuestionForm = (props) => {
  const {ccQuestion, instrumentId, onChange, path} = props;

  const questions = useSelector(state => state.cc_questions);
  const cc_questions = get(questions, instrumentId, {})
  const allQuestionItems = useSelector(state => state.questionItems);
  const questionItems = get(allQuestionItems, instrumentId, {})
  const allQuestionGrids = useSelector(state => state.questionGrids);
  const questionGrids = get(allQuestionGrids, instrumentId, {})

  const [questionOptions, setQuestionOptions] = useState((ccQuestion.question_type === 'QuestionGrid') ? questionGrids : questionItems);

  const changeQuestionOptions = (question_type) => {
    setQuestionOptions((question_type === 'QuestionGrid') ? questionGrids : questionItems)
  }

  const dispatch = useDispatch();
  const classes = useStyles();

  const onSubmit = (values) => {
    if(isNil(ccQuestion.id)){
      dispatch(CcQuestions.create(instrumentId, values))
    }else{
      dispatch(CcQuestions.update(instrumentId, ccQuestion.id, values))
    }

    onChange({node: values, path: path})
  }

  return (
    <div style={{ padding: 16, margin: 'auto', maxWidth: 1000 }}>
      <ObjectStatusBar id={ccQuestion.id || 'new'} type={'CcQuestion'} />
      <CssBaseline />
      <Form
        onSubmit={onSubmit}
        initialValues={ccQuestion}
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
                      ? item.field([])
                      : item.field
                    }
                  </Grid>
                ))}
                <OnChange name="question_type">
                  {(value, previous) => {
                    changeQuestionOptions(value)
                    values.question_id = null
                  }}
                </OnChange>
                <Grid item xs="12" key="Umm">
                  <Select
                    name="question_id"
                    label="Question"
                    formControlProps={{ margin: 'none' }}
                  >
                    <MenuItem></MenuItem>
                    {Object.values(questionOptions).map((item, idx) => (
                      <MenuItem value={item.id}>{item.label}</MenuItem>
                    ))}
                  </Select>
                </Grid>
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
                <DeleteObjectButton id={values.id} instrumentId={instrumentId} action={CcQuestions} />
              </Grid>
            </Paper>
          </form>
        )}
      />
    </div>
  );
}

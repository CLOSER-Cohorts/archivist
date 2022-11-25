import React from 'react';
import { get, isNil } from "lodash";
import { Form } from 'react-final-form';
import { useDispatch, useSelector } from 'react-redux'
import { CodeLists } from '../actions'
import { ObjectStatusBar } from '../components/ObjectStatusBar'
import { DeleteObjectButton } from '../components/DeleteObjectButton'
import { ObjectCheckForInitialValues } from '../support/ObjectCheckForInitialValues'
import { UsedByQuestions } from '../components/UsedByQuestions'
import arrayMutators from 'final-form-arrays'
import { FieldArray } from 'react-final-form-arrays'
import { makeStyles } from '@material-ui/core/styles';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableContainer from '@material-ui/core/TableContainer';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Autocomplete from '@material-ui/lab/Autocomplete';
import DeleteIcon from '@material-ui/icons/Delete';
import ArrowUpwardIcon from '@material-ui/icons/ArrowUpward';
import ArrowDownwardIcon from '@material-ui/icons/ArrowDownward';
import AddCircleOutlineIcon from '@material-ui/icons/AddCircleOutline';

import {
  TextField,
  Checkboxes,
} from 'mui-rff';
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
  small: {
    width: 100
  }
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
        multiline
      />
    ),
  },
  {
    size: 12,
    field: (
      <Checkboxes
        name="rd"
        formControlProps={{ margin: 'none' }}
        data={{ label: 'Response Domain', value: true }}
      />
    ),
  },
  {
    size: 12,
    visible: (values) => {
      return get(values, 'rd', false)
    },
    field: <TextField name="min_responses" multiline label="Min Responses" margin="none" />,
  },
  {
    size: 12,
    visible: (values) => {
      return get(values, 'rd', false)
    },
    field: <TextField name="max_responses" multiline label="Max Responses" margin="none" />,
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

export const CodeListForm = (props) => {
  const {codeList, instrumentId, instrument} = props;

  const categories = useSelector(state => get(state.categories, instrumentId, {}));

  const dispatch = useDispatch();
  const classes = useStyles();

  const onSubmit = (values) => {
      values = ObjectCheckForInitialValues(codeList, values)

    if(isNil(codeList.id)){
      dispatch(CodeLists.create(instrumentId, values))
    }else{
      values.codes.map((code, i) => {
        code.order = i + 1
        return code
      })
      dispatch(CodeLists.update(instrumentId, codeList.id, values))
    }
  }

  return (
    <div style={{ padding: 0 }}>
      <ObjectStatusBar id={codeList.id || 'new'} type={'CodeList'} />
      <CssBaseline />
      <Form
        onSubmit={onSubmit}
        initialValues={codeList}
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
                <h3>Codes</h3>
                {instrument && !instrument.signed_off && (
                  <AddCircleOutlineIcon onClick={() => push('codes', {})}/>
                )}
                <TableContainer component={Paper}>
                  <Table className={classes.table} aria-label="simple table">
                    <TableHead>
                      <TableRow>
                        <TableCell className={classes.small} >ID</TableCell>
                        <TableCell className={classes.small} >Order</TableCell>
                        <TableCell className={classes.small} size="small">Value</TableCell>
                        <TableCell>Category</TableCell>
                        <TableCell className={classes.small}>Actions</TableCell>
                      </TableRow>
                    </TableHead>
                    <TableBody>
                            <FieldArray name="codes">
                              {({ fields }) =>
                                fields.map((name, index) => (
                                  <TableRow key={name}>
                                    <TableCell className={classes.small} >
                                      {fields.value[index].id}
                                    </TableCell>
                                    <TableCell className={classes.small} >
                                      {instrument && !instrument.signed_off && (
                                      <>
                                        {index !== 0 && (
                                          <span
                                            onClick={() => {
                                              fields.move(index, index - 1)
                                            }}
                                            style={{ cursor: 'pointer' }}
                                          >
                                            <ArrowUpwardIcon />
                                          </span>
                                        )}
                                        {index !== fields.length - 1 && (
                                          <span
                                            onClick={() => { fields.move(index, index + 1) }}
                                            style={{ cursor: 'pointer' }}
                                          >
                                            <ArrowDownwardIcon />
                                          </span>
                                        )}
                                      </>
                                      )}
                                    </TableCell>
                                    <TableCell className={classes.small} size="small">
                                      <TextField name={`${name}.value`} multiline label="Value" margin="none" />
                                    </TableCell>
                                    <TableCell>
                                     <Autocomplete
                                      freesolo="true"
                                      options={Object.values(categories)}
                                      getOptionLabel={(option) => option.label}
                                      onChange={(event, value, reason)=>{
                                        if(isNil(value)){
                                          fields.update(index, {...fields.value[index], ...{category_id: null, label: null} })
                                        }else{
                                          fields.update(index, {...fields.value[index], ...{category_id: value.id, label: value.label} })
                                        }
                                      } }
                                      inputValue={ fields.value[index].label || "" }
                                      getOptionSelected={(option, value) => {
                                        return option.id === value.id
                                      }}
                                      renderInput={(params) => (
                                        <TextField name={`${name}.label`}
                                          {...params}
                                          variant="outlined"
                                          label="Label"
                                          placeholder="label"
                                        />
                                      )}
                                    />
                                    </TableCell>
                                    <TableCell className={classes.small}>
                                      {instrument && !instrument.signed_off && (
                                        <span
                                          onClick={() => fields.remove(index)}
                                          style={{ cursor: 'pointer' }}
                                        >
                                          <DeleteIcon />
                                        </span>
                                      )}
                                    </TableCell>
                                  </TableRow>
                                ))
                              }
                            </FieldArray>
                    </TableBody>
                  </Table>
                </TableContainer>
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
                    <DeleteObjectButton id={values.id} instrumentId={instrumentId} action={CodeLists} />
                </>
              )}
              </Grid>
              <UsedByQuestions item={codeList} instrumentId={instrumentId} />
            </Paper>
          </form>
        )}
      />
    </div>
  );
}

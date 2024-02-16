import React, { useEffect } from 'react';
import { get, isNil } from "lodash";
import { Form } from 'react-final-form';
import { useDispatch, useSelector } from 'react-redux'
import { QuestionGrids, ResponseDomainNumerics, ResponseDomainTexts, ResponseDomainDatetimes, ResponseDomainCodes, CodeLists } from '../actions'
import { ObjectStatusBar } from '../components/ObjectStatusBar'
import { DeleteObjectButton } from '../components/DeleteObjectButton'
import { ObjectCheckForInitialValues } from '../support/ObjectCheckForInitialValues'
import arrayMutators from 'final-form-arrays'
import { FieldArray } from 'react-final-form-arrays'
import { OnChange } from 'react-final-form-listeners'
import { makeStyles } from '@material-ui/core/styles';

import {
  TextField,
  Select as RFFSelect
} from 'mui-rff';
import {
  Paper,
  Grid,
  Button,
  CssBaseline,
  MenuItem,
  Table,
  TableContainer,
  TableBody,
  TableHead,
  TableRow,
  TableCell,
  Select
} from '@material-ui/core';

import DeleteIcon from '@material-ui/icons/Delete';


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
      <TextField
        label="Instruction"
        name="instruction"
        margin="none"
        multiline
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
        multiline
      />
    ),
  },
  {
    type: 'select',
    size: 12,
    field: (options) => (
      <RFFSelect
        name="horizontal_code_list_id"
        label="Horizontal Code List (X)"
        formControlProps={{ margin: 'none' }}
      >
        <MenuItem></MenuItem>
        {options.map((item, idx) => (
          <MenuItem value={item.id}>{item.label}</MenuItem>
        ))}
      </RFFSelect>
    ),
  },
  {
      type: 'select',
      size: 12,
      field: (options) => (
        <RFFSelect
          name="vertical_code_list_id"
          label="Vertical Code List (Y)"
          formControlProps={{ margin: 'none' }}
        >
          <MenuItem></MenuItem>
          {options.map((item, idx) => (
            <MenuItem value={item.id}>{item.label}</MenuItem>
          ))}
        </RFFSelect>
      )
  },
  {
      type: 'select',
      size: 12,
      field: (options) => (
        <RFFSelect
          name="corner_label"
          label="Corner Label"
          formControlProps={{ margin: 'none' }}
        >
          <MenuItem></MenuItem>
          <MenuItem value='H'>Horizontal</MenuItem>
          <MenuItem value='V'>Vertical</MenuItem>
        </RFFSelect>
      )
  },
  {
    size: 12,
    field: (
      <TextField
        label="Roster Label"
        name="roster_label"
        margin="none"
        multiline
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
        multiline
      />
    ),
  }
];

export const QuestionGridForm = (props) => {
  const {questionGrid, instrumentId, instrument} = props;

  var codeLists = useSelector(state => get(state.codeLists, instrumentId, {}));

  // Only show response domains in the list of codeLists
  codeLists = Object.values(codeLists).filter((cl) => { return cl.rd === false})

  const dispatch = useDispatch();
  const classes = useStyles();

  const onSubmit = (values, form) => {
    values = ObjectCheckForInitialValues(questionGrid, values)

    if(isNil(questionGrid.id)){
      dispatch(QuestionGrids.create(instrumentId, values, form.reset))
    }else{
      dispatch(QuestionGrids.update(instrumentId, questionGrid.id, values))
    }
  }

  const responseDomainCodes = useSelector(state => get(state.responseDomainCodes, instrumentId, {}));
  const responseDomainNumerics = useSelector(state => get(state.responseDomainNumerics, instrumentId, {}));
  const responseDomainTexts = useSelector(state => get(state.responseDomainTexts, instrumentId, {}));
  const responseDomainDatetimes = useSelector(state => get(state.responseDomainDatetimes, instrumentId, {}));

  const responseDomains = [...Object.values(responseDomainCodes), ...Object.values(responseDomainNumerics), ...Object.values(responseDomainTexts), ...Object.values(responseDomainDatetimes)].sort((a, b) => a.label.localeCompare(b.label))

  useEffect(() => {
    dispatch(ResponseDomainCodes.all(instrumentId));
    dispatch(ResponseDomainNumerics.all(instrumentId));
    dispatch(ResponseDomainTexts.all(instrumentId));
    dispatch(ResponseDomainDatetimes.all(instrumentId));
    dispatch(CodeLists.all(instrumentId));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  // Deep cloning so that we go back to the original QuestioGrid if the user selects the original code list
  const originalQuestionGrid = JSON.parse(JSON.stringify(questionGrid));

  const OnChangeComponent = ({ form, originalQuestionGrid, codeLists }) => {
    return (
      <OnChange name="horizontal_code_list_id">
        {(value, previous) => {
          if (value !== previous) {
            form.batch(() => {
              if (value === originalQuestionGrid.horizontal_code_list_id) {
                // Clear existing entries
                while (form.getState().values.cols.length > 0) {
                  form.mutators.pop('cols');
                }                
                // If the value is the same as the original, reset the cols to the original include the rd attributes
                originalQuestionGrid.cols.forEach((col, index) => {
                  form.change(`cols[${index}]`, col);
                });
              } else {
                const codeList = codeLists.find(el => el.id === value);
                if (codeList) {
                  // Clear existing entries
                  while (form.getState().values.cols.length > 0) {
                    form.mutators.pop('cols');
                  }
                  
                  // Add new entries
                  codeList.codes.forEach((code) => {
                    form.mutators.push('cols', {
                      label: code.label,
                      value: code.value,
                      order: code.order,
                    });
                  });
                }
              }
            });
          }
        }}
      </OnChange>
    );
  };
  

  return (
    <div style={{ padding: 0 }}>
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
              <OnChangeComponent
                form={form}
                originalQuestionGrid={originalQuestionGrid}
                codeLists={codeLists}
              />
                <h3>Response Domains</h3>
                <TableContainer component={Paper}>
                    <Table className={classes.table} aria-label="simple table">
                      <TableHead>
                        <TableRow>
                          <TableCell className={classes.small} >Column</TableCell>
                          <TableCell>Label and Type</TableCell>
                          <TableCell className={classes.small} >Actions</TableCell>
                        </TableRow>
                      </TableHead>
                      <TableBody>
                        <FieldArray name="cols">
                          {({ fields }) =>
                            fields.map((name, index) => (
                              <TableRow key={name}>
                                <TableCell className={classes.small} >{fields.value[index].label}</TableCell>
                                <TableCell>
                                  <Select
                                    label="Label"
                                    name="rd"
                                    variant="outlined"
                                    value={get(fields.value[index].rd, 'id', '')}
                                    onChange={(event) => {
                                      var rd;
                                      var value = event.target.value;

                                      if (isNil(value)) {
                                        rd = { ...fields.value[index].rd, ...{ type: '', id: '', label: '' } }
                                      } else {
                                        value = responseDomains.find(rd => { return rd.id == value })
                                        rd = { ...fields.value[index].rd, ...{ type: value.type, id: value.id, label: value.label } }
                                      }

                                      fields.map((n, i) => {
                                        // We need to update all the fields otherwise if we update a single field then any other cols are cleared of their data.
                                        if(i === index){
                                          fields.update(i, { ...fields.value[i], ...{ rd: rd } })
                                        }else{
                                          fields.update(i, { ...fields.value[i] })
                                        }
                                      })
                                    }}
                                  >
                                    <MenuItem value="">
                                      <em>None</em>
                                    </MenuItem>
                                    {responseDomains.map((rd) => (
                                      <MenuItem value={rd.id}>{`${rd.label} - ${rd.type}`}</MenuItem>
                                    ))}
                                  </Select>
                                </TableCell>
                                <TableCell className={classes.small} >
                                  <span
                                    onClick={() => fields.update(index, {...fields.value[index], ...{rd: {type: '', id: null, label: ''} } }) }
                                    style={{ cursor: 'pointer' }}
                                  >
                                    <DeleteIcon />
                                  </span>
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
                    <DeleteObjectButton id={values.id} instrumentId={instrumentId} action={QuestionGrids} />
                  </>
                )}
              </Grid>
            </Paper>
          </form>
        )}
      />
    </div>
  );
}

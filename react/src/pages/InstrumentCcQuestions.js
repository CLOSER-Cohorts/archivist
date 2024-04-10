import React, { useEffect, useState  } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { CcQuestions } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { DataTable } from '../components/DataTable'
import { get, isNil, difference } from "lodash";
import Chip from '@material-ui/core/Chip';
import DescriptionIcon from '@material-ui/icons/Description';
import { Grid, Box } from '@material-ui/core';
import Select from '@material-ui/core/Select';
import MenuItem from '@material-ui/core/MenuItem';
import { Instrument, ResponseUnits } from '../actions'
import Loader from 'react-spinners/BounceLoader';
import { ObjectStatusBar } from '../components/ObjectStatusBar'
import { makeStyles } from '@material-ui/core/styles';
import { ObjectColour } from '../support/ObjectColour';
import { Paper } from '@material-ui/core'

const IntervieweeList = ({ instrumentId }) => {
  const dispatch = useDispatch();
  const allResponseUnits = useSelector(state => state.response_units);
  const responseUnits = get(allResponseUnits, instrumentId, {});
  const [dataLoaded, setDataLoaded] = useState(false);

  const handleChange = (event, value, reason) => {
    console.log(event.target.value)
    if(!isNil(event.target.value)){
      if (window.confirm("Are you sure you want to update all CcQuestions?")) {
        dispatch(CcQuestions.update_all(instrumentId, {response_unit_id: event.target.value}, (object) => {
          dispatch(CcQuestions.all(instrumentId))
        }))
      }
    }
  }

  const classes = makeStyles({
    paper:{
      boxShadow :`5px 5px 15px 5px  #${ObjectColour('question')}`
    }
  });

  useEffect(() => {
    Promise.all([
      dispatch(Instrument.show(instrumentId)),
      dispatch(ResponseUnits.all(instrumentId))
    ]).then(() => setDataLoaded(true)).catch((error) => console.error("Error loading data:", error));
  }, [dispatch, instrumentId]);

  const intervieweeOptions = () => {
    const allOptions = ['Cohort/sample member', 'Main parent of cohort/sample member', 'Partner of main parent/Father', 'Child of cohort/panel member', 'Proxy', 'Interviewer', 'Other'];
    const rdOptions = Object.values(responseUnits).map(item => item.label);
    return difference(allOptions, rdOptions);
  };

  return dataLoaded ? (
    <Paper style={{ padding: 16 }} className={classes.paper}>
      <ObjectStatusBar id={instrumentId} type={'CcQuestionUpdateAll'} />      
      <h3>Bulk Update all CcQuestions</h3>
      <span className="MuiFormLabel-root MuiInputLabel-animated">
        Update Response Unit Label for all CcQuestions
      </span>
      <Select
        name="response_unit_id"
        label="Interviewee"
        required
        value={" "}
        onChange={handleChange}
      >
        <MenuItem key="placeholder" value=" ">Select an option</MenuItem>
        {Object.values(responseUnits).map((item, idx) => (
          <MenuItem key={item.id} value={item.id}>{item.label}</MenuItem>
        ))}
        {intervieweeOptions().map((item, idx) => (
          <MenuItem key={`option-${idx}`} value={item}>{item}</MenuItem>
        ))}
      </Select>
    </Paper>
  ) : <Loader />;
};

const InstrumentCcQuestions = (props) => {

  const dispatch = useDispatch()
  const instrumentId = get(props, "match.params.instrument_id", "")

  const actions = (row) => {
    return ''
  }

  const headers = ["ID", "Label", "Base Label", "Response Unit Label"]
  const rowRenderer = (row) => {
    return [row.id, row.label, row.base_label, row.response_unit_label]
  }

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'CcQuestions'} instrumentId={instrumentId}>
        <h1>CcQuestions</h1>
        <Box mb={2} pt={3}>
          <Grid container spacing={3}>
            <Grid item xs={5}>
              <IntervieweeList instrumentId={instrumentId} />
            </Grid>
            <Grid item xs={5}>
            </Grid>          
            <Grid item xs={2}>
              <a href={`${process.env.REACT_APP_API_HOST}/instruments/${instrumentId}/cc_questions.tsv?token=${window.localStorage.getItem('jwt')}`}>
                <Chip icon={<DescriptionIcon />} variant="outlined" color="primary" label={'Download File'}></Chip>
              </a>
            </Grid>
          </Grid>
        </Box>
        <DataTable actions={actions}
          fetch={[dispatch(CcQuestions.all(instrumentId))]}
          stateKey={'cc_questions'}
          parentStateKey={instrumentId}
          searchKey={'label'}
          headers={headers}
          sortKeys={[{ key: 'label', label: 'Label' },{ key: 'id', label: 'ID' }]}
          rowRenderer={rowRenderer}
          />
      </Dashboard>
    </div>
  );
}

export default InstrumentCcQuestions;

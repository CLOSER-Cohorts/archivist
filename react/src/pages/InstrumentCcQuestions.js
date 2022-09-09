import React, {  } from 'react';
import { useDispatch } from 'react-redux'
import { CcQuestions } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { DataTable } from '../components/DataTable'
import { get } from 'lodash'
import Chip from '@material-ui/core/Chip';
import DescriptionIcon from '@material-ui/icons/Description';
import { Grid, Box } from '@material-ui/core';
import Divider from '@material-ui/core/Divider';

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
        <Box m={2} pt={3}>
        <Grid container spacing={3}>
          <Grid item xs={10}></Grid>
          <Grid item xs={2}>
            <a href={`${process.env.REACT_APP_API_HOST}/instruments/${instrumentId}/cc_questions.txt?token=${window.localStorage.getItem('jwt')}`}>
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

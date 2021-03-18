/* eslint-disable no-use-before-define */
import React from 'react';
import { useSelector } from 'react-redux'
import TextField from '@material-ui/core/TextField';
import Autocomplete from '@material-ui/lab/Autocomplete';
import { makeStyles } from '@material-ui/core/styles';
import { get } from "lodash";

const useStyles = makeStyles({
  option: {
    fontSize: 15,
    '& > span': {
      marginRight: 10,
      fontSize: 18,
    },
  },
});

export const MoveConstructSelect = ({instrumentId, onMove=()=>{}}) => {
  const classes = useStyles();

  const flatTree = useSelector(state => get(state.instrumentTrees, instrumentId, []));

  return (
    <Autocomplete
      id="country-select-demo"
      style={{ width: 300 }}
      options={flatTree}
      classes={{
        option: classes.option,
      }}
      onChange={onMove}
      autoHighlight
      getOptionLabel={(option) => option.title}
      renderOption={(option) => (
        <React.Fragment>
          {option.title}
        </React.Fragment>
      )}
      renderInput={(params) => (
        <TextField
          {...params}
          label="Move to parent construct"
          variant="outlined"
          inputProps={{
            ...params.inputProps,
            autoComplete: 'new-password', // disable autocomplete and autofill
          }}
        />
      )}
    />
  );
}

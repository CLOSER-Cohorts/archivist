import React from 'react';
import Chip from '@material-ui/core/Chip';
import ErrorIcon from '@material-ui/icons/Error';
import CheckCircleIcon from '@material-ui/icons/CheckCircle';
import WatchLaterIcon from '@material-ui/icons/WatchLater';
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles((theme) => ({
  error: {
    backgroundColor: '#f2dede'
  }
}));

export const SuccessFailureChip = (props) => {
  const { outcome } = props;
  const classes = useStyles();
  if (outcome === 'success') {
    return (
      <Chip icon={<CheckCircleIcon />} variant="outlined" color="primary" label={outcome}></Chip>
    )
  } else if (outcome === 'failure') {
    return (
      <Chip icon={<ErrorIcon />} variant="outlined" color="secondary" label={outcome}></Chip>
    )
  } else {
    return (
      <Chip icon={<WatchLaterIcon />} variant="outlined" color="primary" label={outcome}></Chip>
    )
  } 
}

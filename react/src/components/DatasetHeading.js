import React from 'react';
import { get, isEmpty } from "lodash";
import { makeStyles } from '@material-ui/core/styles';
import { Typography } from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
  heading: {
    paddingRight: theme.spacing(3),
  }
}));

export const DatasetHeading = ({dataset, mode='view'}) => {
  console.log(dataset)
  const classes = useStyles();
  const study = get(dataset, 'study')

  return (
    <Typography variant="h5">
      <span className={classes.heading}>{(isEmpty(study)) ? "" : `${study} - ` }{get(dataset, 'name')}</span>
    </Typography>
  )
}

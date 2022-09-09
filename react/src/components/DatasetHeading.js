import React from 'react';
import { get, isEmpty } from "lodash";
import { makeStyles } from '@material-ui/core/styles';
import { Typography, Grid } from '@material-ui/core';
import Chip from '@material-ui/core/Chip';
import DescriptionIcon from '@material-ui/icons/Description';

const useStyles = makeStyles((theme) => ({
  heading: {
    paddingRight: theme.spacing(3),
  }
}));

export const DatasetHeading = ({dataset, mode='view'}) => {
  const classes = useStyles();
  const study = get(dataset, 'study')

  return (
    <Grid container spacing={3}>
        <Grid item xs={10}>
          <Typography variant="h5">
            <span className={classes.heading}>{(isEmpty(study)) ? "" : `${study} - `}{get(dataset, 'name')}</span>
          </Typography>
        </Grid>
        <Grid item xs={2}>
          { dataset && (
          <Chip icon={<DescriptionIcon />} variant="outlined" color="primary" label={get(dataset, 'filename')}></Chip>
          )}
        </Grid>
    </Grid>
  )
}

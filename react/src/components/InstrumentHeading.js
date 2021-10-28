import React from 'react';
import { get, isEmpty } from "lodash";
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
import Button from '@material-ui/core/Button';
import { makeStyles, withStyles } from '@material-ui/core/styles';
import { Typography } from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
  heading: {
    paddingRight: theme.spacing(3),
  }
}));

export const InstrumentHeading = ({instrument, mode='view'}) => {
  const classes = useStyles();
  const study = get(instrument, 'study')

  return (
    <Typography variant="h5">
      <span className={classes.heading}>{(isEmpty(study)) ? "" : `${study} - `}{get(instrument, 'label')}</span>
      { instrument && (
        <>
        { mode !== 'view' && (
          <Button variant="outlined">
            <Link to={url(routes.instruments.instrument.show, { instrument_id: instrument.slug })}>View</Link>
          </Button>
        )}
        { mode !== 'build' && (
          <Button variant="outlined">
            <Link to={url(routes.instruments.instrument.build.show, { instrument_id: instrument.slug })}>Build</Link>
          </Button>
        )}
        { mode !== 'map' && (
          <Button variant="outlined">
            <Link to={url(routes.instruments.instrument.map.show, { instrument_id: instrument.slug })}>Map</Link>
          </Button>
        )}
        </>
      )}
    </Typography>
  )
}

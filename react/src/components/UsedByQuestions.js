import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableContainer from '@material-ui/core/TableContainer';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'

import {
  Paper,
  Grid,
  Button,
} from '@material-ui/core';


const useStyles = makeStyles({
  table: {
    minWidth: 650,
  },
  small: {
    width: 100
  }
});

export const UsedByQuestions = (props) => {
  const {item, instrumentId} = props;

  const classes = useStyles();

  return (
      <Grid item style={{ marginTop: 16 }}>
        <h3>Used By</h3>
        <TableContainer component={Paper}>
          <Table className={classes.table} aria-label="simple table">
            <TableHead>
              <TableRow>
                <TableCell>ID</TableCell>
                <TableCell size="small">Question Type</TableCell>
                <TableCell>Label</TableCell>
              </TableRow>
            </TableHead>
            {item.used_by && (
            <TableBody>
                      {item.used_by.map((question) => (
                          <TableRow key={question.id}>
                            <TableCell>
                              <Button variant="outlined">
                                <Link to={url(routes.instruments.instrument.build.questionItems.show, { instrument_id: instrumentId, questionItemId: question.id })}>{question.id}</Link>
                              </Button>
                            </TableCell>
                            <TableCell size="small">
                              {question.type}
                            </TableCell>
                            <TableCell size="small">
                              {question.label}
                            </TableCell>
                          </TableRow>
                        ))
                      }
            </TableBody>
            )}
          </Table>
        </TableContainer>
      </Grid>
  );
}

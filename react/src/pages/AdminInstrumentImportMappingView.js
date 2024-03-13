import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { AdminImportMapping } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { SuccessFailureChip } from '../components/SuccessFailureChip'
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Grid from '@material-ui/core/Grid';
import Box from '@material-ui/core/Box';
import Typography from '@material-ui/core/Typography';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import Chip from '@material-ui/core/Chip';
import DescriptionIcon from '@material-ui/icons/Description';
import { makeStyles } from '@material-ui/core/styles';
import { get, isNil } from 'lodash'

const useStyles = makeStyles((theme) => ({
  error: {
    backgroundColor: '#f2dede'
  }
}));

const InstrumentImportView = (props) => {
  const { instrumentImport } = props;

  const classes = useStyles();

  return(
    <Grid item xs={12}  >

      <Box fontWeight="fontWeightLight" m={2} >
        <Typography variant="h5" component="p" >
          Instrument Import
        </Typography>
      </Box>

      <Grid container spacing={4}>
        <Grid item xs={3}>
          <Box fontWeight="fontWeightLight" m={2} >
            <Card className={classes.card}>
              <CardContent>
              <Typography variant="h6" component="h4">
                  Import Type
                </Typography>
                <Typography className={classes.pos} color="textSecondary">
                  {instrumentImport.import_type}
                </Typography>                
                <Typography variant="h6" component="h4">
                  State
                </Typography>
                <Typography className={classes.pos} color="textSecondary">
                  <SuccessFailureChip outcome={instrumentImport.state} />
                </Typography>
              </CardContent>
            </Card>
          </Box>
        </Grid>
        <Grid item xs={4}>
          <Box fontWeight="fontWeightLight" m={2} >
            <Card className={classes.card}>
              <CardContent>
                <Typography variant="h5" component="h2">
                  Document
                </Typography>
                <Typography className={classes.pos} color="textSecondary">
                  { instrumentImport.filename }
                </Typography>
                <Typography variant="body2" component="p">
                  <a href={`${process.env.REACT_APP_API_HOST}/instruments/${instrumentImport.instrument_id}/imports/${instrumentImport.id}/document.json?token=${window.localStorage.getItem('jwt')}`}>
                    <Chip icon={<DescriptionIcon />} variant="outlined" color="primary" label={'Download File'}></Chip>
                  </a>
                </Typography>
              </CardContent>
            </Card>
          </Box>
        </Grid>
        <Grid item xs={4}>
          <Box fontWeight="fontWeightLight" m={2} >
            <Card className={classes.card}>
              <CardContent>
                <Typography variant="h5" component="h2">
                  Created At
                </Typography>
                <Typography className={classes.pos} color="textSecondary">
                  { instrumentImport.created_at }
                </Typography>
              </CardContent>
            </Card>
          </Box>
        </Grid>
      </Grid>

    </Grid>
  )
}

const AdminInstrumentImportMappingView = (props) => {

  const dispatch = useDispatch()
  const instrumentId = get(props, "match.params.instrumentId", "")
  const importMappingId = get(props, "match.params.id", "")
  const imports = useSelector(state => get(state.instrumentImportMappings, instrumentId));
  const importObj = get(imports, importMappingId, { logs: [] })
  const logs = get(importObj, 'logs', [])
  const rows: RowsProp = Object.values(logs);
  const classes = useStyles();

  useEffect(() => {
    dispatch(AdminImportMapping.show('instruments', instrumentId, importMappingId));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'InstrumentImports'}>        
        <InstrumentImportView instrumentImport={importObj} />
        <Table size="small">
          <TableHead>
            <TableRow>
              <TableCell>Input</TableCell>
              <TableCell>Matches</TableCell>
              <TableCell>Outcome</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {rows.map((row) => (
              <TableRow key={row.id} style={ isNil(row.error) ? {} : { background : '#f2dede' } }>
                <TableCell>{row.original_text}</TableCell>
                <TableCell>{row.matches}</TableCell>
                <TableCell>{row.outcome}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Dashboard>
    </div>
  );
}

export default AdminInstrumentImportMappingView;

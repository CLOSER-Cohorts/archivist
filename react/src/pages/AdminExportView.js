import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { AdminExport } from '../actions'
import { Dashboard } from '../components/Dashboard'
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import { get } from 'lodash'
import { SuccessFailureChip } from '../components/SuccessFailureChip';
import Grid from '@material-ui/core/Grid';
import Box from '@material-ui/core/Box';
import Typography from '@material-ui/core/Typography';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import Chip from '@material-ui/core/Chip';
import DescriptionIcon from '@material-ui/icons/Description';
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles((theme) => ({
  error: {
    backgroundColor: '#f2dede'
  }
}));

const InstrumentExportView = (props) => {
  const { instrumentExport } = props;

  const classes = useStyles();

  return(
    <Grid item xs={12}  >

      <Box fontWeight="fontWeightLight" m={2} >
        <Typography variant="h5" component="p" >
          Export
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
                  {instrumentExport.import_type}
                </Typography>                
                <Typography variant="h6" component="h4">
                  State
                </Typography>
                <Typography className={classes.pos} color="textSecondary">
                  <SuccessFailureChip outcome={instrumentExport.state} />
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
                  { instrumentExport.filename }
                </Typography>
                <Typography variant="body2" component="p">
                  <a href={`${process.env.REACT_APP_API_HOST}/exports/${instrumentExport.id}/document.json?token=${window.localStorage.getItem('jwt')}`}>
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
                  { instrumentExport.created_at }
                </Typography>
              </CardContent>
            </Card>
          </Box>
        </Grid>
      </Grid>

    </Grid>
  )
}

const AdminExportView = (props) => {

  const dispatch = useDispatch()
  const exportId = get(props, "match.params.exportId", "")
  const exports = useSelector(state => state.exports);
  const exportObj = get(exports, exportId, { logs: [] })
  const logs = get(exportObj, 'logs', [])
  const rows: RowsProp = Object.values(logs);

  useEffect(() => {
    dispatch(AdminExport.show(exportId));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'DDI exports'}>
        <InstrumentExportView instrumentExport={exportObj} />
        <Table size="small">
          <TableHead>
            <TableRow>
              <TableCell>Input</TableCell>
              <TableCell>Outcome</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {rows.map((row) => (
              <TableRow key={row.id}>
                <TableCell style={{ maxWidth: 400, backgroundColor: '#f0f0f0', fontFamily: 'monospace', whiteSpace: 'pre-wrap', wordBreak: 'break-all', padding: '8px' }}><code>{row.original_text}</code></TableCell>
                <TableCell>{row.outcome}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Dashboard>
    </div>
  );
}

export default AdminExportView;

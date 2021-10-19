import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { AdminImportMapping } from '../actions'
import { Dashboard } from '../components/Dashboard'
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Card from '@material-ui/core/Card';
import CardHeader from '@material-ui/core/CardHeader';
import CardContent from '@material-ui/core/CardContent';
import { makeStyles } from '@material-ui/core/styles';
import { get, isNil } from 'lodash'

const useStyles = makeStyles((theme) => ({
  error: {
    backgroundColor: '#f2dede'
  }
}));

const AdminDatasetImportMappingView = (props) => {

  const dispatch = useDispatch()
  const datasetId = get(props, "match.params.datasetId", "")
  const importMappingId = get(props, "match.params.id", "")
  const imports = useSelector(state => get(state.datasetImportMappings, datasetId));
  const importObj = get(imports, importMappingId, { logs: [] })
  const logs = get(importObj, 'logs', [])
  const rows: RowsProp = Object.values(logs);
  const classes = useStyles();

  useEffect(() => {
    dispatch(AdminImportMapping.show('datasets', datasetId, importMappingId));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'DatasetImports'}>
        <ul>
          <li>Filename : {importObj.filename}</li>
          <li>State : {importObj.state}</li>
          <li>Created At : {importObj.created_at}</li>
        </ul>
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

export default AdminDatasetImportMappingView;

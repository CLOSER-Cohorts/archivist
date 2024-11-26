import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { AdminExport } from '../actions'
import { Dashboard } from '../components/Dashboard'
import { SuccessFailureChip } from '../components/SuccessFailureChip';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import TableFooter from '@material-ui/core/TableFooter';
import TablePagination from '@material-ui/core/TablePagination';
import Button from '@material-ui/core/Button';
import Chip from '@material-ui/core/Chip';
import DescriptionIcon from '@material-ui/icons/Description';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
import { get } from 'lodash'

const AdminExports = () => {

  const dispatch = useDispatch()
  const exports = useSelector(state => state.exports);
  const [page, setPage] = React.useState(0);
  const [rowsPerPage, setRowsPerPage] = React.useState(20);

  const rows: RowsProp = Object.values(exports).sort().reverse();

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  useEffect(() => {
    dispatch(AdminExport.all());
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'DDI Exports'}>
        <Table size="small">
          <TableHead>
            <TableRow>
              <TableCell>ID</TableCell>
              <TableCell>Instrument</TableCell>
              <TableCell>Type</TableCell>
              <TableCell>State</TableCell>
              <TableCell>Created At</TableCell>
              <TableCell>Exported File</TableCell>
              <TableCell>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {rows.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map((row) => (
              <TableRow key={row.id}>
                <TableCell>{row.id}</TableCell>
                <TableCell>
                {get(row, 'dataset_id') && (
                  <Link to={url(routes.datasets.dataset.edit, { dataset_id: row.dataset_id })}>
                    {row.dataset_id}
                  </Link>
                )}
                {get(row, 'instrument_prefix') && (
                  <Link to={url(routes.instruments.instrument.map.show, { instrument_id: row.instrument_prefix })}>
                    {row.instrument_prefix}
                  </Link>
                )}
                </TableCell>
                <TableCell>{row.export_type}</TableCell>
                <TableCell><SuccessFailureChip outcome={row.state}/></TableCell>
                <TableCell>{row.created_at}</TableCell>
                <TableCell>
                {row.state === 'success' && (
                    <a href={`${process.env.REACT_APP_API_HOST}/exports/${row.id}/document.json?token=${window.localStorage.getItem('jwt')}`}>
                      <Chip icon={<DescriptionIcon />} variant="outlined" color="primary" label="Download File" />
                    </a>
                )}
                </TableCell>
                <TableCell>                                 
                  <Button variant="outlined">
                      <Link to={url(routes.admin.exports.show, { exportId: row.id })}>
                        View Log
                      </Link>
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
         <TableFooter>
            <TableRow>
              <TablePagination
                rowsPerPageOptions={[20, 50, 100, { label: 'All', value: -1 }]}
                colSpan={3}
                count={rows.length}
                rowsPerPage={rowsPerPage}
                page={page}
                onChangePage={handleChangePage}
                onChangeRowsPerPage={handleChangeRowsPerPage}
                SelectProps={{
                  inputProps: { 'aria-label': 'rows per page' },
                  native: true,
                }}
              />
            </TableRow>
          </TableFooter>
        </Table>
      </Dashboard>
    </div>
  );
}

export default AdminExports;

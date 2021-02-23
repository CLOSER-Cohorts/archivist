import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Instrument } from '../actions'
import { Dashboard } from '../components/Dashboard'
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import TableFooter from '@material-ui/core/TableFooter';
import TablePagination from '@material-ui/core/TablePagination';
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'

const AdminInstruments = () => {

  const dispatch = useDispatch()
  const instruments = useSelector(state => state.instruments);
  const [page, setPage] = React.useState(0);
  const [rowsPerPage, setRowsPerPage] = React.useState(20);

  const rows: RowsProp = Object.values(instruments);

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  useEffect(() => {
     dispatch(Instrument.all());
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Admin Instruments'}>
        <Table size="small">
          <TableHead>
            <TableRow>
              <TableCell>ID</TableCell>
              <TableCell>Prefix</TableCell>
              <TableCell>Study</TableCell>
              <TableCell>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {rows.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map((row) => (
              <TableRow key={row.id}>
                <TableCell>{row.id}</TableCell>
                <TableCell>{row.prefix}</TableCell>
                <TableCell>{row.study}</TableCell>
                <TableCell>
                  <Button variant="outlined">
                    Edit
                  </Button>
                  <Button variant="outlined">
                    Copy
                  </Button>
                  <Button variant="outlined">
                    Import Mappings
                  </Button>
                  <Button variant="outlined">
                    QV
                  </Button>
                  <Button variant="outlined">
                    Topics
                  </Button>
                  <Button variant="outlined">
                    View Imports
                  </Button>
                  <Button variant="outlined">
                    Clear Cache
                  </Button>
                  <Button variant="outlined">
                    Delete
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

export default AdminInstruments;

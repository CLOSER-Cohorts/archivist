import React, { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Dataset } from '../actions'
import { Dashboard } from '../components/Dashboard'
import ButtonGroup from '@material-ui/core/ButtonGroup';
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

const AdminDatasets = () => {

  const dispatch = useDispatch()
  const datasets = useSelector(state => state.datasets);
  const [page, setPage] = React.useState(0);
  const [rowsPerPage, setRowsPerPage] = React.useState(20);

  const rows: RowsProp = Object.values(datasets);

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  useEffect(() => {
     dispatch(Dataset.all());
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Admin Datasets'}>
        <Table size="small">
          <TableHead>
            <TableRow>
              <TableCell>ID</TableCell>
              <TableCell>Name</TableCell>
              <TableCell>Study</TableCell>
              <TableCell>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {rows.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map((row) => (
              <TableRow key={row.id}>
                <TableCell>{row.id}</TableCell>
                <TableCell>{row.name}</TableCell>
                <TableCell>{row.study}</TableCell>
                <TableCell>
                <ButtonGroup variant="outlined">
                  <Button>
                    Edit
                  </Button>
                  <Button>
                    Import Mappings
                  </Button>
                  <Button>
                    DV
                  </Button>
                  <Button>
                    Topics
                  </Button>
                  <Button>
                    View Imports
                  </Button>
                  <Button>
                    Delete
                  </Button>
                 </ButtonGroup>
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

export default AdminDatasets;

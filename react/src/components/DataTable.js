import React, { useEffect, useState } from 'react';
import { useSelector } from 'react-redux'
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Divider from '@material-ui/core/Divider';
import TableFooter from '@material-ui/core/TableFooter';
import TablePagination from '@material-ui/core/TablePagination';
import SearchBar from "material-ui-search-bar";
import { Loader } from '../components/Loader'

export const DataTable = (props) => {

  const { actions=()=>{}, fetch=[], stateKey='instruments', searchKey='prefix', headers=[], rowRenderer=()=>{} } = props;
  const values = useSelector(state => state[stateKey]);
  const [page, setPage] = React.useState(0);
  const [rowsPerPage, setRowsPerPage] = React.useState(20);
  const [search, setSearch] = useState("");
  const [filteredValues, setFilteredValues] = useState([]);
  const [dataLoaded, setDataLoaded] = useState(false);

  useEffect(() => {
    setFilteredValues(
      Object.values(values).filter((value) =>
        value[searchKey].toLowerCase().includes(search.toLowerCase())
      )
    );
  }, [search, values]);

  const rows: RowsProp = filteredValues;

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  useEffect(() => {
    Promise.all(fetch).then(() => {
      setDataLoaded(true)
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  },[]);

  return (
    <>
        {!dataLoaded
        ? <Loader />
        : (
          <>
            <SearchBar
              placeholder="Search (press return to perform search)"
              onChange={(newValue) =>
                      setSearch(newValue)
                    }
              onRequestSearch={(newValue) =>
                      setSearch(newValue)
                    }
              onCancelSearch={() => {
                      setSearch('')
                    }}
            />
            <Divider style={{ margin: 16 }} variant="middle" />
            <Table size="small">
              <TableHead>
                <TableRow>
                  {headers.map((header)=>(
                    <TableCell>{header}</TableCell>
                  ))}
                  <TableCell>Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {rows.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map((row) => (
                  <TableRow key={row.id}>
                    {rowRenderer(row).map((cell)=>(
                      <TableCell>{cell}</TableCell>
                    ))}
                    <TableCell>
                      {actions(row)}
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
          </>
        )}
  </>
  );
}

export default DataTable;

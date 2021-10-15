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
import { get, isEmpty, isInteger } from 'lodash'
import InputLabel from '@material-ui/core/InputLabel';
import Select from '@material-ui/core/Select';
import Grid from '@material-ui/core/Grid';

export const DataTable = (props) => {

  const { actions=()=>{}, fetch=[], stateKey='instruments', searchKey='prefix', headers=[], rowRenderer=()=>{}, parentStateKey, sortKeys=[] } = props;
  let { searchKeys = [searchKey], filters = [] } = props;

  let values = useSelector(state => state[stateKey]);

  filters = filters.map((filter)=>{
    filter.options = [...new Set(Object.values(values).map((o) => o[filter.key]))]
    filter.options = filter.options.sort().map((option) => {
      return {value: option, label: option}
    })
    return filter
  })

  if(parentStateKey){
    values = get(values, parentStateKey, {})
  }

  const [page, setPage] = React.useState(0);
  const [rowsPerPage, setRowsPerPage] = React.useState(20);
  const [search, setSearch] = useState("");
  const [filteredValues, setFilteredValues] = useState([]);
  const [dataLoaded, setDataLoaded] = useState(false);

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

  const [activeFilters, setActiveFilters] = useState({});
  const [sortKey, setSortKey] = useState('id');

  const handleFilter = (event) => {
    const name = event.target.name;
    setActiveFilters({
      ...activeFilters,
      [name]: event.target.value,
    });
  };

  const handleSort = (event) => {
    const name = event.target.name;
    setSortKey(event.target.value);
  };

  useEffect(() => {
    var results = Object.values(values)

    Object.keys(activeFilters).map((filterKey) => {
      if (activeFilters[filterKey] === ''){
        return results
      }
      results = results.filter((value) => {
        return value[filterKey] && value[filterKey].toString().toLowerCase().includes(activeFilters[filterKey].toLowerCase())
      })
    })
    results = results.filter((value) => {
      return searchKeys.some((sk) => {
        return value[sk] && value[sk].toString().toLowerCase().includes(search.toLowerCase())
      })
    })

    if(sortKey == 'id'){
      results = results.sort((a) => a.id).reverse()
    }else{
      results = results.sort((a, b) => {
        var optA = a[sortKey]
        var optB = b[sortKey]

        optA = (isEmpty(optA)) ? '' : optA.toString()
        optB = (isEmpty(optB)) ? '' : optB.toString()
        return optA.localeCompare(optB)
      })
    }

    setFilteredValues(results);
  }, [search, values, activeFilters, sortKey]);

  return (
    <>
        {!dataLoaded
        ? <Loader />
        : (
          <>
            <Grid container spacing={3}>
              <Grid item xs={(isEmpty(filters) ? 12 : 9)}>
                <SearchBar
                  placeholder={`Search by ${searchKey} (press return to perform search)`}
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
                </Grid>
                <Grid item xs={2}>
                  { filters.map((filter)=> (
                    <>
                      <InputLabel htmlFor="filled-age-native-simple">{filter.label}</InputLabel>
                      <Select
                        native
                        value={activeFilters[filter.key]}
                        onChange={handleFilter}
                        inputProps={{
                          name: filter.key,
                          id: 'filled-age-native-simple',
                        }}
                      >
                        <option aria-label="None" value="" />
                        { filter.options.map((option) => (
                          <option value={option.value}>{option.label}</option>
                        ))}
                      </Select>
                    </>
                  ))}
                </Grid>
                <Grid item xs={1}>
                  {!isEmpty(sortKeys) && (
                    <>
                      <InputLabel htmlFor="filled-age-native-simple">Sort By</InputLabel>
                      <Select
                        native
                        onChange={handleSort}
                        inputProps={{
                          name: 'sort',
                          id: 'filled-age-native-simple',
                        }}
                      >
                        {sortKeys.map((option) => (
                          <option value={option.key}>{option.label}</option>
                        ))}
                      </Select>
                    </>
                  )}
                </Grid>
              </Grid>

            <Divider style={{ margin: 16 }} variant="middle" />
            <Table size="small">
              <TableHead>
                <TableRow>
                  {headers.map((header)=>(
                    <TableCell>{header}</TableCell>
                  ))}
                  { !isEmpty(actions({})) && (
                    <TableCell>Actions</TableCell>
                  )}
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

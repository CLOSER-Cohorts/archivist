import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Instrument} from '../actions'
import { Dashboard } from '../components/Dashboard'
import { get, isEmpty } from 'lodash'
import { Loader } from '../components/Loader'
import { Grid, Box, Typography, ButtonGroup } from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import Chip from '@material-ui/core/Chip';
import DescriptionIcon from '@material-ui/icons/Description';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableContainer from '@material-ui/core/TableContainer';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';
import { reverse as url } from 'named-urls'
import routes from '../routes'
import CloudDownloadIcon from '@material-ui/icons/CloudDownload';

const useStyles = makeStyles({
  card: {
    minWidth: 275,
  },
  bullet: {
    display: 'inline-block',
    margin: '0 2px',
    transform: 'scale(0.8)',
  },
  title: {
    fontSize: 14,
  },
  pos: {
    marginBottom: 12,
  },
});

const InstrumentView = (props) => {
  const { instrument } = props;

  const classes = useStyles();

  return(
    <Grid item xs={12}  >

      <Box fontWeight="fontWeightLight" m={2} >
        <Typography variant="h5" component="p" >
          {instrument.label} - {instrument.prefix}
        </Typography>
      </Box>

      <Grid container spacing={3}>
        <Grid item xs={3}>
          <Box fontWeight="fontWeightLight" m={2} >
            <Card className={classes.card}>
              <CardContent>
                <Typography variant="h5" component="h2">
                  QV
                </Typography>
                <Typography className={classes.pos} color="textSecondary">
                  Question Variables
                </Typography>
                <Typography variant="body2" component="p">
                  <a href={`${process.env.REACT_APP_API_HOST}/instruments/${instrument.id}/qv.txt?token=${window.localStorage.getItem('jwt')}`}>
                    <Chip icon={<DescriptionIcon />} variant="outlined" color="primary" label={'Download qv.txt'}></Chip>
                  </a>
                </Typography>
              </CardContent>
            </Card>
          </Box>
        </Grid>
        <Grid item xs={3}>
          <Box fontWeight="fontWeightLight" m={2} >
            <Card className={classes.card}>
              <CardContent>
                <Typography variant="h5" component="h2">
                  TQ
                </Typography>
                <Typography className={classes.pos} color="textSecondary">
                  Topic Questions
                </Typography>
                <Typography variant="body2" component="p">
                  <a href={`${process.env.REACT_APP_API_HOST}/instruments/${instrument.id}/tq.txt?token=${window.localStorage.getItem('jwt')}`}>
                    <Chip icon={<DescriptionIcon />} variant="outlined" color="primary" label={'Download tq.txt'}></Chip>
                  </a>
                </Typography>
              </CardContent>
            </Card>
          </Box>
        </Grid>
        <Grid item xs={3}>
          <Box fontWeight="fontWeightLight" m={2} >
            <Card className={classes.card}>
              <CardContent>
                <Typography variant="h5" component="h2">
                  Mapper
                </Typography>
                <Typography className={classes.pos} color="textSecondary">
                  Topic Questions
                </Typography>
                <Typography variant="body2" component="p">
                  <a href={`${process.env.REACT_APP_API_HOST}/instruments/${instrument.id}/mapper.txt?token=${window.localStorage.getItem('jwt')}`}>
                    <Chip icon={<DescriptionIcon />} variant="outlined" color="primary" label={'Download mapper.txt'}></Chip>
                  </a>
                </Typography>
              </CardContent>
            </Card>
          </Box>
        </Grid>
        <Grid item xs={3}>
          <Box fontWeight="fontWeightLight" m={2} >
            <Card className={classes.card}>
              <CardContent>
                <Typography variant="h5" component="h2">
                  CC Questions
                </Typography>
                <Typography className={classes.pos} color="textSecondary">
                  Construct Questions
                </Typography>
                <Typography variant="body2" component="p">
                  <a href={`${process.env.REACT_APP_API_HOST}/instruments/${instrument.id}/cc_questions.txt?token=${window.localStorage.getItem('jwt')}`}>
                    <Chip icon={<DescriptionIcon />} variant="outlined" color="primary" label={'Download cc_questions.txt'}></Chip>
                  </a>
                </Typography>
              </CardContent>
            </Card>
          </Box>
        </Grid>
      </Grid>
      <Box fontWeight="fontWeightLight" m={2} >
        <Typography variant="h5" component="h2">
          Datasets
        </Typography>
        { isEmpty(instrument.datasets) ? (
          <>No Datasets associated with this Instrument</>
        ) : (
        <Table className={classes.table} aria-label="simple table">
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell align="left">Instance Name</TableCell>
              <TableCell align="left"></TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {instrument.datasets.map((row) => (
              <TableRow key={row.name}>
                <TableCell component="th" scope="row">
                  {row.name}
                </TableCell>
                <TableCell align="left">{row.instance_name}</TableCell>
                <TableCell align="left">
                  <ButtonGroup variant="outlined">
                    <Button>
                      <Link to={url(routes.admin.datasets.dataset.show, { dataset_id: row.id })}>View</Link>
                    </Button>
                  </ButtonGroup>
                  <a href={`${process.env.REACT_APP_API_HOST}/datasets/${row.id}/variables.txt?token=${window.localStorage.getItem('jwt')}`}>
                    <Chip icon={<DescriptionIcon />} variant="outlined" color="primary" label={'variables.txt'}></Chip>
                  </a>
                  <a href={`${process.env.REACT_APP_API_HOST}/datasets/${row.id}/tv.txt?token=${window.localStorage.getItem('jwt')}`}>
                    <Chip icon={<DescriptionIcon />} variant="outlined" color="primary" label={'tv.txt'}></Chip>
                  </a>
                  <a href={`${process.env.REACT_APP_API_HOST}/datasets/${row.id}/dv.txt?token=${window.localStorage.getItem('jwt')}`}>
                    <Chip icon={<DescriptionIcon />} variant="outlined" color="primary" label={'dv.txt'}></Chip>
                  </a>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        )
        }
      </Box>
      <Box fontWeight="fontWeightLight" m={2} >
        <Typography variant="h5" component="h2">
          XML Exports
        </Typography>
        <Table className={classes.table} aria-label="simple table">
          <TableHead>
            <TableRow>
              <TableCell>ID</TableCell>
              <TableCell>Type</TableCell>
              <TableCell align="left">Created At</TableCell>
              <TableCell align="left"></TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {instrument.exports.map((row) => (
              <TableRow key={row.name}>
                <TableCell component="th" scope="row">
                  {row.id}
                </TableCell>
                <TableCell align="left">{row.type}</TableCell>
                <TableCell align="left">{row.created_at}</TableCell>
                <TableCell align="left">
                  <Button variant="contained" color="primary">
                    <a style={{ color: 'white', textDecoration: 'none' }} target={'_blank'} href={process.env.REACT_APP_API_HOST + row.export_url}><CloudDownloadIcon />Download export</a>
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Box>

    </Grid>
  )
}

const AdminInstrumentView = (props) => {

  const dispatch = useDispatch()

  const instrumentId = get(props, "match.params.instrument_id", "")
  const instrument = useSelector(state => get(state.instruments, instrumentId));

  const [dataLoaded, setDataLoaded] = useState(false);

  useEffect(() => {
    Promise.all([
      dispatch(Instrument.show(instrumentId))
    ]).then(() => {
      setDataLoaded(true)
    });
  }, []);

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Instrument Exports'}>
        {!dataLoaded
          ? <Loader />
          : <InstrumentView instrument={instrument}/>
        }
      </Dashboard>
    </div>
  );
}

export default AdminInstrumentView;

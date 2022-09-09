import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux'
import { Dataset} from '../actions'
import { Dashboard } from '../components/Dashboard'
import { get } from 'lodash'
import { Loader } from '../components/Loader'
import { Grid, Box, Typography } from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import Chip from '@material-ui/core/Chip';
import DescriptionIcon from '@material-ui/icons/Description';

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

const DatasetView = (props) => {
  const { dataset } = props;

  const classes = useStyles();

  return(
    <Grid item xs={12}  >

      <Box fontWeight="fontWeightLight" m={2} >
        <Typography variant="h5" component="p" >
          {dataset.name} - {dataset.study}
        </Typography>
      </Box>

      <Grid container spacing={4}>
        <Grid item xs={3}>
          <Box fontWeight="fontWeightLight" m={2} >
            <Card className={classes.card}>
              <CardContent>
                <Typography variant="h5" component="h2">
                  Variables
                </Typography>
                <Typography className={classes.pos} color="textSecondary">
                  Variables
                </Typography>
                <Typography variant="body2" component="p">
                  <a href={`${process.env.REACT_APP_API_HOST}/datasets/${dataset.id}/variables.txt?token=${window.localStorage.getItem('jwt')}`}>
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
                  TV
                </Typography>
                <Typography className={classes.pos} color="textSecondary">
                  Topic Variables
                </Typography>
                <Typography variant="body2" component="p">
                  <a href={`${process.env.REACT_APP_API_HOST}/datasets/${dataset.id}/tv.txt?token=${window.localStorage.getItem('jwt')}`}>
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
                  DV
                </Typography>
                <Typography className={classes.pos} color="textSecondary">
                  Derived Variables
                </Typography>
                <Typography variant="body2" component="p">
                  <a href={`${process.env.REACT_APP_API_HOST}/datasets/${dataset.id}/dv.txt?token=${window.localStorage.getItem('jwt')}`}>
                    <Chip icon={<DescriptionIcon />} variant="outlined" color="primary" label={'Download File'}></Chip>
                  </a>
                </Typography>
              </CardContent>
            </Card>
          </Box>
        </Grid>
      </Grid>

    </Grid>
  )
}

const AdminDatasetView = (props) => {

  const dispatch = useDispatch()

  const datasetId = get(props, "match.params.dataset_id", "")
  const dataset = useSelector(state => get(state.datasets, datasetId));

  const [dataLoaded, setDataLoaded] = useState(false);

  useEffect(() => {
    Promise.all([
      dispatch(Dataset.show(datasetId))
    ]).then(() => {
      setDataLoaded(true)
    });
  }, []);

  return (
    <div style={{ height: 500, width: '100%' }}>
      <Dashboard title={'Dataset Exports'}>
        {!dataLoaded
          ? <Loader />
          : <DatasetView dataset={dataset}/>
        }
      </Dashboard>
    </div>
  );
}

export default AdminDatasetView;

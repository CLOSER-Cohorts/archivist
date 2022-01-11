import React, { useEffect, useState } from 'react';
import { isNil } from "lodash";
import { Form } from 'react-final-form';
import { useDispatch, useSelector } from 'react-redux'
import { UserGroup } from '../actions'
import { User } from '../actions'
import { ObjectStatusBar, ObjectStatus } from '../components/ObjectStatusBar'
import { ObjectCheckForInitialValues } from '../support/ObjectCheckForInitialValues'
import { makeStyles } from '@material-ui/core/styles';
import { Loader } from '../components/Loader'

import {
  Select
} from 'mui-rff';
import {
  MenuItem
} from '@material-ui/core';

import {
  TextField
} from 'mui-rff';
import {
  Paper,
  Grid,
  Button,
  CssBaseline,
} from '@material-ui/core';


const useStyles = makeStyles({
  table: {
    minWidth: 650,
  },
  paper:{
  }
});

const validate = (values) => {

  const errors = {};

  if (!values.email) {
    errors.email = 'Required';
  }

  if (!values.first_name) {
    errors.first_name = 'Required';
  }

  if (!values.last_name) {
    errors.last_name = 'Required';
  }

  if (!values.group_id) {
    errors.group_id = 'Required';
  }

  return errors;
};

const formFields = (item) => {
  return [
    {
      size: 12,
      field: (
        <TextField
          label="Email Address"
          name="email"
          margin="none"
          required={true}
        />
      ),
    },
    {
      size: 12,
      field: (
        <TextField
          label="First Name"
          name="first_name"
          margin="none"
          required={true}
        />
      ),
    },
    {
      size: 12,
      field: (
        <TextField
          label="Last Name"
          name="last_name"
          margin="none"
          required={true}
        />
      ),
    },
    {
      type: 'select',
      size: 12,
      field: (options) => (
        <Select
          name="role"
          label="Role"
          required={true}
          formControlProps={{ margin: 'none' }}
        >
          <MenuItem value={'reader'}>{'Reader'}</MenuItem>
          <MenuItem value={'editor'}>{'Editor'}</MenuItem>
          <MenuItem value={'admin'}>{'Admin'}</MenuItem>
        </Select>
      ),
    },
  ]
}

export const AdminUserForm = (props) => {
  const {user} = props;

  const dispatch = useDispatch();
  const classes = useStyles();

  const status = ObjectStatus(user.id || 'new', 'User')

  const userGroups = useSelector(state => state.userGroups);

  const [dataLoaded, setDataLoaded] = useState(false);

  useEffect(() => {
    Promise.all([
      dispatch(UserGroup.all())
    ]).then(() => {
      setDataLoaded(true)
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);


  const onSubmit = (values) => {

    values = ObjectCheckForInitialValues(user, values)
    if(isNil(user.id)){
      dispatch(User.create(values))
    }else{
      dispatch(User.update(user.id, values))
    }
  }

  return (
    <div style={{ padding: 16, margin: 'auto', maxWidth: 1000 }}>
    {!dataLoaded
      ? <Loader />
      : (
        <>
          <ObjectStatusBar id={user.id || 'new'} type={'User'} />
          <CssBaseline />
          <Form
            onSubmit={onSubmit}
            initialValues={user}
            validate={(values) => validate(values, status)}
            render={({
            handleSubmit,
            form: {
              mutators: { push, pop }
            }, // injected from final-form-arrays above
            pristine,
            form,
            submitting,
            values
          }) => (
              <form onSubmit={handleSubmit} noValidate>
                <Paper style={{ padding: 16 }} className={classes.paper}>
                  <Grid container alignItems="flex-start" spacing={2}>
                    {formFields(user).map((item, idx) => (
                      <Grid item xs={item.size} key={idx}>
                        {item.type && item.type === 'select'
                          ? item.field(userGroups)
                          : item.field
                        }
                      </Grid>
                    ))}
                    <Grid item style={{ marginTop: 16 }}>
                      <Button
                        variant="contained"
                        color="primary"
                        type="submit"
                        disabled={submitting}
                      >
                        Save
                      </Button>
                    </Grid>
                  </Grid>
                </Paper>
              </form>
            )}
          />
        </>
        )}
      </div>
  );
}

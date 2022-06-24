import React, { useState } from 'react';
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';
import CssBaseline from '@material-ui/core/CssBaseline';
import TextField from '@material-ui/core/TextField';
import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core/styles';
import Container from '@material-ui/core/Container';
import { Password } from '../actions'
import { useDispatch } from 'react-redux'
import logo from '../logo.svg';
import routes from '../routes';
import { reverse as url } from 'named-urls'
import { Alert, AlertTitle } from '@material-ui/lab';

const useStyles = makeStyles((theme) => ({
  paper: {
    marginTop: theme.spacing(8),
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
  },
  avatar: {
    margin: theme.spacing(1),
    backgroundColor: theme.palette.secondary.main,
  },
  form: {
    width: '100%', // Fix IE 11 issue.
    marginTop: theme.spacing(1),
  },
  submit: {
    margin: theme.spacing(3, 0, 2),
  },
}));

const useFormField = (initialValue: string = "") => {
  const [value, setValue] = React.useState(initialValue);
  const onChange = React.useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => setValue(e.target.value),
    []
  );
  return { value, onChange };
};

export default function ForgottenPassword() {
  const classes = useStyles();

  const emailField = useFormField();

  const dispatch = useDispatch()

  const [formSubmitted, setFormSubmitted] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setFormSubmitted(true)
    dispatch(Password.forgot(emailField.value));
  }

  return (
    <Container component="main" maxWidth="xs">
      <CssBaseline />
      <div className={classes.paper}>
        <img src={logo} alt="Logo"/>
        <Typography component="h1" variant="h2">
          Archivist
        </Typography>
        <Typography component="h2" variant="h5">
          Forgotten Password
        </Typography>
        {
          formSubmitted && (
            <Alert severity="success">
              If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes.
            </Alert>
          )
        }
        <form className={classes.form} noValidate onSubmit={handleSubmit}>
          <TextField
            variant="outlined"
            margin="normal"
            required
            fullWidth
            id="email"
            label="Email Address"
            name="email"
            autoComplete="email"
            autoFocus
            {...emailField}
          />
          <Button
            type="submit"
            fullWidth
            variant="contained"
            color="primary"
            className={classes.submit}
          >
            Send me reset password instructions
          </Button>
        </form>
      </div>
      or <Link to={url(routes.login)}>Login</Link> here
    </Container>
  );
}

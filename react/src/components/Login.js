import ListErrors from './ListErrors';
import React from 'react';
import agent from '../agent';
import images from '../images';
import { connect } from 'react-redux';
import { Link } from 'react-router-dom';
import {
  UPDATE_FIELD_AUTH,
  LOGIN,
  LOGIN_PAGE_UNLOADED
} from '../constants/actionTypes';

const mapStateToProps = state => (
  {
    ...state.auth,
    common: state.common
  }
);

const mapDispatchToProps = dispatch => ({
  onChangeEmail: value =>
    dispatch({ type: UPDATE_FIELD_AUTH, key: 'email', value }),
  onChangePassword: value =>
    dispatch({ type: UPDATE_FIELD_AUTH, key: 'password', value }),
  onSubmit: (email, password) =>
    dispatch({ type: LOGIN, payload: agent.Auth.login(email, password) }),
  onUnload: () =>
    dispatch({ type: LOGIN_PAGE_UNLOADED })
});

class Login extends React.Component {

  constructor() {
    super();
    this.changeEmail = ev => this.props.onChangeEmail(ev.target.value);
    this.changePassword = ev => this.props.onChangePassword(ev.target.value);
    this.submitForm = (email, password) => ev => {
      ev.preventDefault();
      this.props.onSubmit(email, password);
    };
  }

  componentWillUnmount() {
    this.props.onUnload();
  }

  errorMessage(field) {
    if(this.props.errors && this.props.errors[field]){
      return this.props.errors[field];
    }
  };

  render() {

    const email = this.props.email;
    const password = this.props.password;
    return (

      <main>

        <section className="component__route component__route__login">

          <img src={images.logo} alt="Slate" />

          <ListErrors errors={this.props.errors} />

          <form onSubmit={this.submitForm(email, password)}>

            <h1>Sign in to your Slate account.</h1>

            <div className="field">

              <label>
                <div>Email {this.errorMessage('email') ? <div className="error">{this.errorMessage('email')}</div> : ''}</div>
                <input
                  type="text"
                  value={email}
                  onChange={this.changeEmail} />
              </label>

            </div>

            <div className="field">

              <label>
                <span className="justify">Password <Link to="/password/forgot">Forgot password?</Link></span>
                <input
                  type="password"
                  value={password}
                  onChange={this.changePassword} />
              </label>

            </div>

            <div className="field field__buttons">

              <Link to="/register">Create an account</Link>

              <button
                disabled={this.props.common.loading}
                className={this.props.common.loading ? 'btn btn__loading' : 'btn'}>
                <div className="loader loader__button"></div>
                <span>Sign In</span>
              </button>

            </div>

          </form>

        </section>

      </main>
    );
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(Login);

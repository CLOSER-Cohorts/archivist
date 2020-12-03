import ListErrors from './ListErrors';
import React from 'react';
import agent from '../agent';
import images from '../images';
import { connect } from 'react-redux';
import { Link } from 'react-router-dom';
import {
  PASSWORD_FORGET,
  PASSWORD_FORGET_PAGE_UNLOADED
} from '../constants/actionTypes';

const mapStateToProps = state => ({ ...state.auth });

const mapDispatchToProps = dispatch => ({
  onSubmit: (email) =>
    dispatch({ type: PASSWORD_FORGET, payload: agent.Password.forgot(email) }),
  onUnload: () =>
    dispatch({ type: PASSWORD_FORGET_PAGE_UNLOADED })
});

class ForgottenPassword extends React.Component {
  constructor() {
    super();
    this.submitForm = (email) => ev => {
      ev.preventDefault();
      this.props.onSubmit(email);
    };
    this.state = {
      email: ''
    };
  }

  updateState = field => ev => {

    let newData = update(this.state, {
      [field]: {$set: value}
    })

    this.setState(newData);
    
    // cleanup
    newData = null;

  };

  componentWillUnmount() {
    this.props.onUnload();
  }

  errorMessage(field) {
    if(this.props.errors && this.props.errors[field]){
      return this.props.errors[field];
    }
  };

  render() {
    return (

      <main>

        <section className="component__route component__route__login">

          <img src={images.logo} alt="Slate" />

          <ListErrors errors={this.props.errors} />

          <form onSubmit={this.submitForm(this.state.email)}>

            <h1>Reset your password.</h1>

          {this.props.message &&
            <p class="notice">{this.props.message}</p>
          }
            <div className="field">

              <label>
                <div>Email {this.errorMessage('email') ? <div className="error">{this.errorMessage('email')}</div> : ''}</div>
                <input
                  type="text"
                  value={this.state.email}
                  onChange={this.updateState('email')} />
              </label>

            </div>

            <div className="field field__buttons">

              <Link to="/login">Login</Link>

              <button
                className="btn btn-lg btn-primary pull-xs-right"
                type="submit"
                disabled={this.props.inProgress}>
                Send password reset email
              </button>

            </div>

          </form>

        </section>

      </main>
    );
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(ForgottenPassword);

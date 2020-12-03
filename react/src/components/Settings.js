import React from 'react';
import agent from '../agent';
import { connect } from 'react-redux';
import dateFns from 'date-fns';
import SettingsForm from './SettingsForm';

import {
  SETTINGS_UPDATE,
  SETTINGS_SAVED,
  SUBSCRIPTION_CANCEL,
  SUBSCRIPTION_CREATE,
  SUBSCRIPTION_EXTEND,
  PAYMENT_METHOD_UPDATE,
  OPEN_SETTINGS_OVERLAY,
  CLOSE_SETTINGS_OVERLAY,
  ASYNC_END
} from '../constants/actionTypes';

const mapStateToProps = state => (
  {
    ...state.settings,
    currentUser: state.common.currentUser,
    subscription: state.common.subscription,
    overlay: state.settings.overlay
  }
);

const mapDispatchToProps = dispatch => ({

  onSubmitForm: user => {
    function parse(str) {
      const [date, month, year] = str.split('/').map(n => parseInt(n))
      return new Date(year, month - 1, date)
    }
    user.business_attributes.year_end = dateFns.format(parse(user.business_attributes.year_end + '/2019'), 'DD/MM/YYYY')
    dispatch({ type: SETTINGS_SAVED, payload: agent.Auth.save(user) })
    dispatch({ type: SETTINGS_UPDATE })
  },

  createSubscription: (stripe_token_id, type) => {
    dispatch({ type: SUBSCRIPTION_CREATE, payload: agent.Subscription.create(stripe_token_id, type) })
    dispatch({ type: CLOSE_SETTINGS_OVERLAY })
    dispatch({ type: ASYNC_END })
  },

  updatePayment: (stripe_token_id, type) => {
    dispatch({ type: PAYMENT_METHOD_UPDATE, payload: agent.PaymentMethod.create(stripe_token_id) })
  },

  cancelSubscription: subscription_id => {
    dispatch({ type: SUBSCRIPTION_CANCEL, payload: agent.Subscription.remove(subscription_id) })
  },

  pauseSubscription: subscription_id => {
    dispatch({ type: SUBSCRIPTION_EXTEND, payload: agent.Subscription.extend(subscription_id) })

    dispatch({
      type: SUBSCRIPTION_EXTEND,
      payload: agent.Subscription.extend(subscription_id).then((res) => {
        if(!res.body.errors) {
          dispatch({ type: CLOSE_SETTINGS_OVERLAY });
        }
        return res;
      })
    })

  },

  openOverlay: () => {
    dispatch({ type: OPEN_SETTINGS_OVERLAY });
  },

  closeOverlay: () => {
    dispatch({ type: CLOSE_SETTINGS_OVERLAY });
  }

});

class Settings extends React.Component {

  handleCancel = (e) => {

    console.log('hello')

    e.preventDefault();
    this.props.openOverlay()
  }

  render() {
    return (
      <section className="component__route component__route__settings">
        <header>
          <h2>Settings</h2>
        </header>
        <section>
          <SettingsForm
            subscription={this.props.subscription}
            currentUser={this.props.currentUser}
            errors={this.props.errors}
            inProgress={this.props.inProgress}
            success={this.props.success}
            onSubmitForm={this.props.onSubmitForm}
            handleCancel={this.handleCancel}
            createSubscription={this.props.createSubscription}
            overlay={this.props.overlay}
            closeOverlay={this.props.closeOverlay}
            updatePayment={this.props.updatePayment}
            cancelSubscription={this.props.cancelSubscription}
            pauseSubscription={this.props.pauseSubscription}/>
        </section>
      </section>
    );
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(Settings);
import React from 'react';
import InputMask from 'react-input-mask';
import { Elements, StripeProvider } from 'react-stripe-elements';
import CheckoutForm from './CheckoutForm';
import dateFns from 'date-fns';
import Select from 'react-select';
import countryList from 'react-select-country-list';
import update from 'immutability-helper';
import { components } from 'react-select';
import { connect } from 'react-redux';

const STRIPE_PUBLISHABLE_KEY = process.env.REACT_APP_STRIPE_PUBLISHABLE_KEY;
const Input = ({ autoComplete, ...props }) => <components.Input {...props} autoComplete="new-password" />;

const mapStateToProps = state => (
  {
    ...state,
    loading: state.common.loading
  }
);

class SettingsForm extends React.Component {
  constructor(props) {
    super();
    this.countries = countryList().getData();
    this.state = {
      name: props.currentUser ? props.currentUser.name : '',
      email: props.currentUser ? props.currentUser.email : '',
      standard_hourly_rate: props.currentUser ? props.currentUser.standard_hourly_rate : '',
      standard_day_rate: props.currentUser ? props.currentUser.standard_day_rate : '',
      monthly_revenue_target: props.currentUser ? (props.currentUser.monthly_revenue_target === 0 ? '' : props.currentUser.monthly_revenue_target) : '',
      monday: props.currentUser ? props.currentUser.monday : false,
      tuesday: props.currentUser ? props.currentUser.tuesday : false,
      wednesday: props.currentUser ? props.currentUser.wednesday : false,
      thursday: props.currentUser ? props.currentUser.thursday : false,
      friday: props.currentUser ? props.currentUser.friday : false,
      saturday: props.currentUser ? props.currentUser.saturday : false,
      sunday: props.currentUser ? props.currentUser.sunday : false,
      hours_per_day: props.currentUser.hours_per_day ? props.currentUser.hours_per_day : 7,
      work_on_public_holidays: props.currentUser ? props.currentUser.work_on_public_holidays : false,
      dark_mode: props.currentUser ? props.currentUser.dark_mode : false,
      unsubscribe_from_emails: props.currentUser ? props.currentUser.unsubscribe_from_emails : false,
      currency: props.currentUser ? props.currentUser.currency : 'GBP',
      business_attributes: {
        id: props.currentUser ? props.currentUser.business.id : null,
        name: props.currentUser ? props.currentUser.business.name : '',
        year_end: props.currentUser ? dateFns.format(props.currentUser.business.year_end, 'DD/MM') : ''
      },
      country: props.currentUser.country ? {
        value: props.currentUser.country,
        label: countryList().getLabel(props.currentUser.country)
      } : false
    };
  }
  errorMessage(field) {
    if (this.props.errors && this.props.errors[field]) {
      return this.props.errors[field];
    }
  }
  ;
  updateState = field => ev => {
    const [split_field, parent_key] = field.split('.').reverse();
    const value = ev.target.type === 'checkbox' ? ev.target.checked : ev.target.value;
    let newData;
    if (parent_key === undefined) {
      newData = update(this.state, {
        [split_field]: { $set: value }
      });
    }
    else {
      newData = update(this.state, {
        [parent_key]: {
          [split_field]: { $set: value }
        }
      });
    }
    this.setState(newData);
    // cleanup
    newData = null;
  };
  updateCurrency = (field, value) => ev => {
    const [split_field, parent_key] = field.split('.').reverse();
    let newData;
    if (parent_key === undefined) {
      newData = update(this.state, {
        [split_field]: { $set: value }
      });
    }
    else {
      newData = update(this.state, {
        [parent_key]: {
          [split_field]: { $set: value }
        }
      });
    }
    this.setState(newData);
    // cleanup
    newData = null;
  };
  updateCountry = value => {
    this.setState({ country: value });
  };
  submitForm(ev) {
    ev.preventDefault();
    let newData = update(this.state, {
      'country': { $set: this.state.country.value }
    });
    this.props.onSubmitForm(newData);
    // cleanup
    newData = null;
    return false;
  }
  handleClick = () => {
    this.setState({ displayColorPicker: !this.state.displayColorPicker });
  };
  handleClose = () => {
    this.setState({ displayColorPicker: false });
  };
  handleChange = (color) => {
    this.setState({
      hex_colour: color.hex
    });
  };
  render() {
    let trial_remaining;
    let invoices;
    if (this.props.currentUser && !this.props.currentUser.admin && this.props.currentUser.state === 'trialing' && this.props.currentUser.trial_ends_at) {
      trial_remaining = dateFns.differenceInDays(this.props.currentUser.trial_ends_at, dateFns.parse(Date.now()));
    }
    if (this.props.currentUser.invoices.length > 0) {
      invoices = true;
    }
    return (<div>

      {!this.props.currentUser.admin &&
        <div className="group">

          <div className="field">
            {(this.props.subscription && this.props.subscription.state !== 'canceled') &&
              <React.Fragment>
                <h2>You're subscribed to the {this.props.subscription.plan_name} plan.</h2>
                <p>Your next payment will be <b>{this.props.subscription.amount}</b> on {dateFns.format(this.props.subscription.next_invoice_at, 'DD/MM/YYYY')} using your {this.props.subscription.payment_method.brand} card ending in {this.props.subscription.payment_method.last4}. You can cancel your subscription or update your payment method below.</p>
              </React.Fragment>}
            {(!this.props.subscription || this.props.subscription.state === 'canceled') &&
              <React.Fragment>
                <h2>Payment details</h2>
              </React.Fragment>}
          </div>

          <StripeProvider apiKey={STRIPE_PUBLISHABLE_KEY}>
            <Elements>
              <CheckoutForm
                showform={false}
                currentUser={this.props.currentUser}
                subscription={this.props.subscription}
                cancel={this.props.cancelSubscription}
                pause={this.props.pauseSubscription}
                handleCancel={this.props.handleCancel}
                overlay={this.props.overlay}
                closeOverlay={this.props.closeOverlay}
                loading={this.props.loading}
                submit={(this.props.subscription) ? this.props.updatePayment : this.props.createSubscription} />
            </Elements>
          </StripeProvider>

          {invoices && (<div className="invoices">
            {this.props.currentUser.invoices.map((item) => {
              return (<div key={item.created_at} className="invoice">
                <span>{dateFns.format(item.created_at, 'MMMM YYYY')} ({item.amount})</span>
                <a href={item.url} target="_blank" rel="noopener noreferrer">Download Invoice</a>
              </div>);
            })}
          </div>)}

          {trial_remaining &&
            <div className="trial">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16">
                <g fill="none" stroke="currentColor" strokeLinecap="round" strokeLinejoin="round" strokeMiterlimit="10">
                  <circle cx="8.5" cy="8.5" r="7" /><path d="M8.5 4.5v4h4" />
                </g>
              </svg>
              <span>You have {dateFns.differenceInDays(this.props.currentUser.trial_ends_at, dateFns.parse(Date.now()))} days left of your trial</span>
            </div>}

        </div>}

      <form onSubmit={this.submitForm.bind(this)}>

        <div className="group">

          <div className="field">
            <label>
              Name {this.errorMessage('name')}
              <input className="form-control" type="text" value={this.state.name} onChange={this.updateState('name')} />
            </label>
          </div>

          <div className="field">
            <label>
              Email {this.errorMessage('email')}
              <input className="form-control" type="text" value={this.state.email} onChange={this.updateState('email')} />
            </label>
          </div>

          <div className="field">
            <label>
              Company Name
              <input className="form-control" type="text" value={this.state.business_attributes.name} onChange={this.updateState('business_attributes.name')} />
            </label>
          </div>

          <div className="field">
            <label>
              <span>Company Year End (DD/MM)</span>
              <InputMask mask="99 / 99" maskChar='_' placeholder="DD / MM" value={this.state.business_attributes.year_end} onChange={this.updateState('business_attributes.year_end')} />
            </label>
            <small>We'll use this to calculate the financial health of your business.</small>
          </div>

          <div className="field">

            <label>
              <span>Country</span>
            </label>
            <Select className="react-select-container" classNamePrefix="react-select" options={this.countries} value={this.state.country} onChange={this.updateCountry} components={{
              Input
            }} />

          </div>

        </div>

        <div className="group">

          <h3>Currency Format</h3>

          <div className="field__group">

            <div className="field field__checkbox">
              <label>
                <input className="form-control" type="checkbox" checked={this.state.currency === 'GBP'} onChange={this.updateCurrency('currency', 'GBP')} />
                <span className="currency">£ {this.errorMessage('currency')}</span>
              </label>
            </div>
            <div className="field field__checkbox">
              <label>
                <input className="form-control" type="checkbox" checked={this.state.currency === 'USD'} onChange={this.updateCurrency('currency', 'USD')} />
                <span className="currency">$ {this.errorMessage('currency')}</span>
              </label>
            </div>
            <div className="field field__checkbox">
              <label>
                <input className="form-control" type="checkbox" checked={this.state.currency === 'EUR'} onChange={this.updateCurrency('currency', 'EUR')} />
                <span className="currency">€ {this.errorMessage('currency')}</span>
              </label>
            </div>
            <div className="field field__checkbox">
              <label>
                <input className="form-control" type="checkbox" checked={this.state.currency === 'DKK'} onChange={this.updateCurrency('currency', 'DKK')} />
                <span className="currency">kr. {this.errorMessage('currency')}</span>
              </label>
            </div>
            <div className="field field__checkbox">
              <label>
                <input className="form-control" type="checkbox" checked={this.state.currency === 'BRL'} onChange={this.updateCurrency('currency', 'BRL')} />
                <span className="currency">R$ {this.errorMessage('currency')}</span>
              </label>
            </div>

          </div>

          <div className={"field field__helper field__helper-" + this.state.currency.toLowerCase()}>
            <label>
              <span>Standard Day Rate {this.errorMessage('standard_day_rate')}</span>
              <div className="helper">
                <input className="form-control" type="text" value={this.state.standard_day_rate} onChange={this.updateState('standard_day_rate')} />
              </div>
            </label>
          </div>

          <div className={"field field__helper field__helper-" + this.state.currency.toLowerCase()}>
            <label>
              <span>Standard Hourly Rate {this.errorMessage('standard_hourly_rate')}</span>
              <div className="helper">
                <input className="form-control" type="text" value={this.state.standard_hourly_rate} onChange={this.updateState('standard_hourly_rate')} />
              </div>
            </label>
          </div>

          <div className={"field field__helper field__helper-" + this.state.currency.toLowerCase()}>
            <label>
              <span>Monthly Revenue Target {this.errorMessage('monthly_revenue_target')}</span>
              <div className="helper">
                <input className="form-control" type="text" value={this.state.monthly_revenue_target} onChange={this.updateState('monthly_revenue_target')} />
              </div>
            </label>
            <small>How much do you need to earn a month to pay your expenses and salary?</small>
          </div>

        </div>

        <div className="group">

          <h3>Which days do you work?</h3>

          <div className="field__group">

            <div className="field field__checkbox">
              <label>
                <input className="form-control" type="checkbox" checked={this.state.monday} onChange={this.updateState('monday')} />
                <span>Monday {this.errorMessage('monday')}</span>
              </label>
            </div>
            <div className="field field__checkbox">
              <label>
                <input className="form-control" type="checkbox" checked={this.state.tuesday} onChange={this.updateState('tuesday')} />
                <span>Tuesday {this.errorMessage('tuesday')}</span>
              </label>
            </div>
            <div className="field field__checkbox">
              <label>
                <input className="form-control" type="checkbox" checked={this.state.wednesday} onChange={this.updateState('wednesday')} />
                <span>Wednesday {this.errorMessage('wednesday')}</span>
              </label>
            </div>
            <div className="field field__checkbox">
              <label>
                <input className="form-control" type="checkbox" checked={this.state.thursday} onChange={this.updateState('thursday')} />
                <span>Thursday {this.errorMessage('thursday')}</span>
              </label>
            </div>
            <div className="field field__checkbox">
              <label>
                <input className="form-control" type="checkbox" checked={this.state.friday} onChange={this.updateState('friday')} />
                <span>Friday {this.errorMessage('friday')}</span>
              </label>
            </div>
            <div className="field field__checkbox">
              <label>
                <input className="form-control" type="checkbox" checked={this.state.saturday} onChange={this.updateState('saturday')} />
                <span>Saturday {this.errorMessage('saturday')}</span>
              </label>
            </div>
            <div className="field field__checkbox">
              <label>
                <input className="form-control" type="checkbox" checked={this.state.sunday} onChange={this.updateState('sunday')} />
                <span>Sunday {this.errorMessage('sunday')}</span>
              </label>
            </div>

          </div>

          <div className={"field field__helper field__helper-" + this.state.currency.toLowerCase()}>
            <label>
              <span>How many hours is your work day? {this.errorMessage('hours_per_day')}</span>
              <input className="form-control" type="text" value={this.state.hours_per_day} onChange={this.updateState('hours_per_day')} />
            </label>
          </div>

          <div className="field field__switch">
            <label>
              <span>Do you work on public holidays? {this.errorMessage('work_on_public_holidays')}</span>
              <input className="form-control" type="checkbox" checked={this.state.work_on_public_holidays} onChange={this.updateState('work_on_public_holidays')} />
              <span />
            </label>
          </div>

        </div>

        <div className="group">

          <div className="field field__switch">
            <label>
              <span>Do you want to turn on dark mode? {this.errorMessage('dark_mode')}</span>
              <input className="form-control" type="checkbox" checked={this.state.dark_mode} onChange={this.updateState('dark_mode')} />
              <span />
            </label>
          </div>

          <div className="field field__switch">
            <label>
              <span>Unsubscribe from emails? {this.errorMessage('unsubscribe_from_emails')}</span>
              <input className="form-control" type="checkbox" checked={this.state.unsubscribe_from_emails} onChange={this.updateState('unsubscribe_from_emails')} />
              <span />
            </label>
          </div>

        </div>

        <div className="field field__fixed">
          <button className="btn" type="submit" disabled={this.props.inProgress}>
            Save Settings
          </button>
        </div>

        {this.props.inProgress && <div className="success">Settings updated</div>}

      </form>

    </div>);
  }
}

export default connect(mapStateToProps, false)(SettingsForm);

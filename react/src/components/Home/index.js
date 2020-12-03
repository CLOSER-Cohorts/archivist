import React from 'react';
import ReactDOM from 'react-dom';
import { Link } from 'react-router-dom';
import { connect } from 'react-redux';
import dateFns from 'date-fns';
import _ from 'lodash';
import { Info } from '../Info';
import Tasks from '../Tasks/index';
import { ResponsiveContainer, ComposedChart, Line, XAxis, Tooltip, ReferenceLine } from 'recharts';
import {default as HelpTooltip} from '../Tooltip';
import {ReactComponent as ErrorIcon} from '../../images/error.svg';
import {ReactComponent as PositiveIcon} from '../../images/positive.svg';
import {ReactComponent as PriceIcon} from '../../images/icons/price.svg';

import agent from '../../agent';
import {
  MONTH_LOADED,
  YEAR_LOADED
} from '../../constants/actionTypes';

const mapStateToProps = state => (
  {
    ...state.common,
    ...state.clients,
    ...state.projects,
    monthData: state.months.data,
    yearData: state.years.data,
    currentUser: state.common.currentUser,
    currentMonth: state.common.currentMonth,
    currentYear: state.common.currentUser.current_year,
  }
);

const mapDispatchToProps = dispatch => ({
  loadMonth: (month) => {
    let month_name = dateFns.format(month, 'MMMM').toLowerCase()
    let year = dateFns.format(month, 'YYYY').toLowerCase()
    dispatch({ type: MONTH_LOADED, month: month, month_string: month_name + '-' + year, payload: agent.Month.show(month_name, year) })
  },
  loadYear: (year) => {
    dispatch({ type: YEAR_LOADED, payload: agent.Year.show(year) })
  }
});

const CustomTooltip = (props) => {

  var formatter = new Intl.NumberFormat( navigator.language, {
    style: 'currency',
    currency: props.currency,
    maximumFractionDigits: 0,
    minimumFractionDigits: 0
  });

  if (props.active && props.payload) {

    return (

      ReactDOM.createPortal(
        <div>
          {props.payload[0].payload.name}<br />
          {dateFns.isFuture(Date.parse( props.payload[0].payload.name )) && "Forecast"} Cumulative Total is {formatter.format(props.payload[0].payload.forecast)}
        </div>,
        document.querySelector('div.status')
      )

    )

  }

  return null;

}

class Home extends React.Component {

  constructor(props) {
    super(props);

    this.state = {
      notifications: true,
      multipleDates: [],
      shift: false,
      selectedKeys: [],
      deleteKeys: [],
      selectorEnabled: true
    }

  }

  componentWillMount() {
    this.props.loadMonth(this.props.currentMonth)
    this.props.loadYear(this.props.currentUser.current_year)
  }

  componentWillUnmount() {
  }

  componentDidUpdate() {

  }

  clearNotifications = (e) => {

    this.setState(prevState => ({
      notifications: !prevState.notifications
    }));

  }

  formatPrice(price) {

    return new Intl.NumberFormat(this.props.locale, {
      style: 'currency',
      currency: this.props.currentUser.currency,
      maximumFractionDigits: 0,
      minimumFractionDigits: 0
    }).format(price)

  }

  render() {

    if(this.props.monthData && this.props.yearData && this.props.projects && this.props.clients){

      const revenue_data = [];
      let revenue_forecast = 0;

      this.props.yearData.month_breakdown.filter(function(item) {
        if( item.cumulative_revenue === 0 && !dateFns.isThisMonth(Date.parse( item.month_name )) && dateFns.isPast(Date.parse( item.month_name )) ) {
          return false;
        }
        return true;
      }).map((item, key) => {

        if (item.revenue === 0 || item.revenue < this.props.yearData.monthly_average_revenue)
          revenue_forecast += this.props.yearData.monthly_average_revenue
        else
          revenue_forecast += item.revenue

        const date = Date.parse( item.month_date );
        const past = dateFns.isPast(date);

        return(
          revenue_data.push({
            key: ++key,
            number: item.month_number,
            month: dateFns.format(date, 'MMM'),
            target: this.props.currentUser.monthly_revenue_target * item.month_number,
            forecast: past ? item.cumulative_revenue : revenue_forecast,
            earned: past ? ( item.cumulative_revenue === 0 ? null : item.cumulative_revenue) : null,
            name: item.month_name
          })
        )

        }
      )

      // add unscheduled project revenue to forecast
      revenue_forecast += this.props.yearData.unscheduled_project_revenue

      // add unscheduled project revenue to last month in year
      revenue_data[revenue_data.length-1].forecast += this.props.yearData.unscheduled_project_revenue

      var formatter = new Intl.NumberFormat( navigator.language, {
        style: 'currency',
        currency: this.props.currentUser.currency,
        maximumFractionDigits: 0,
        minimumFractionDigits: 0,
        notation: 'compact'
      });

      const forecast =  revenue_forecast;
      //const annual_estimate = formatter.format( forecast )
      const annual_estimate_low_range = Math.round( forecast * 0.95 /1000 ) * 1000
      const annual_estimate_high_range = Math.round( forecast * 1.05 /1000 ) * 1000
      const annual_estimate_low_range_string = formatter.format( annual_estimate_low_range )
      const annual_estimate_high_range_string = formatter.format( annual_estimate_high_range )

      const in_range = _.inRange(this.props.yearData.yearly_target, annual_estimate_low_range - 1, annual_estimate_high_range + 1)

      const next_month_name = dateFns.format(dateFns.addMonths(new Date(), 1), 'MMMM').toLowerCase()
      const next_month = this.props.yearData.month_breakdown.filter(function(item) {
        if( item.month === next_month_name) {
          return true;
        }
        return false;
      })

      const risks = {
        "count" : 0,
        "revenue" : [],
        "productivity" : [],
        "availability": []
      }

      // check if your average monthly revenue lower than target
      if ( this.props.yearData.yearly_target >= forecast || in_range ) {
        risks.revenue.push( in_range ? {
          title: "Could miss annual target",
          tooltip: "It's going to be close if you meet your annual target"
        } : {
          title: "Annual target",
          tooltip: "We don't think you'll meet your annual target"
        })
        ++risks.count
      }

      // check if you're going to miss target for this month
      if ( this.props.monthData.revenue < this.props.currentUser.monthly_revenue_target ) {
        risks.revenue.push({
          title: this.props.monthData.month_name + " " + this.props.monthData.year + " Target",
          tooltip: "We don't think you'll meet your target for " + this.props.monthData.month_name + " " + this.props.monthData.year
        })
        ++risks.count
      }

      // check if your day rate is lower than standard
      if ( this.props.yearData.average_day_rate < this.props.currentUser.standard_day_rate ) {
        risks.productivity.push({
          title: "Avg. day rate is " + this.props.yearData.average_day_rate_formatted,
          tooltip: "Your standard day rate is " + this.props.currentUser.standard_day_rate_formatted
        })
        ++risks.count
      }

      // check if you've got enough work scheduled for next month
      if ( next_month[0].revenue < this.props.currentUser.monthly_revenue_target ) {
        risks.revenue.push({
          title: next_month[0].month_name + " Target",
          tooltip: "We don't think you'll meet your target for " + next_month[0].month_name
        })
        ++risks.count
      }

      // check if you've got less than 20% of work booked for the next 2 months
      if ( this.props.yearData.total_productivity_forecast_percentage < 20) {
        risks.productivity.push({
          title: "Low % of days planned",
          tooltip: "You don't have much work scheduled for the future."
        })
        ++risks.count
      }

      // check if you've worked less than 60% of available days so far this year
      if ( this.props.yearData.total_productivity_percentage < 60) {
        risks.productivity.push({
          title: "High % of days unpaid",
          tooltip: "You haven't worked for a lot of days this year."
        })
        ++risks.count
      }

      return (
        <React.Fragment>
          <section className="component__route component__route__dashboard">

            <header>
              <h2>Dashboard</h2>
              <span>Here’s a summary of how your business is doing</span>
            </header>

            <section>

              <div>

                {this.props.yearData.amount_agreed !== 0 && (
                <div className={ (risks.count > 0 && this.props.yearData.amount_agreed !== 0) ? 'message message__issue' : 'message message__success'}>

                  { (risks.count > 0 && this.props.yearData.amount_agreed !== 0) ? <ErrorIcon /> : <PositiveIcon /> }

                  <div>{ (risks.count > 0 && this.props.yearData.amount_agreed !== 0) ? "We've spotted a few risks in your business" : "Everything looks good, nice work!"}</div>

                </div>
                )}

                <div className="data">

                  <div className="component__tasks">

                    <h2>Reminders</h2>

                    <Tasks
                      clients={this.props.clients.length}
                      amountAgreed={this.props.yearData.amount_agreed}
                      activeMonth={this.props.currentMonth} />
                  </div>

                </div>

                {( (this.props.yearData.amount_revenue === 0) && (this.props.yearData.amount_agreed === 0) ) ? (
                  <React.Fragment>
                  <div className="data">

                    <div>

                      <h2>Revenue</h2>

                      <p>Add some work to your schedule to get a breakdown of your revenue.</p>

                    </div>

                    {(this.props.yearData.unscheduled_project_revenue > 0) && (
                    <div className="pending">
                      <PriceIcon />
                      <span>You have { this.props.yearData.unscheduled_project_revenue_formatted } from fixed price projects that are yet to be scheduled.</span>
                    </div>
                    )}

                  </div>
                  <div className="data">

                    <div>

                      <h2>Performance</h2>

                      <p>Add some work to your schedule to get a breakdown of your performance.</p>

                    </div>

                  </div>
                  </React.Fragment>
                ):(
                  <React.Fragment>
                  <div className="data">

                    <div className="data__left">

                      <h3>Revenue</h3>

                      <h2>{ revenue_forecast < this.props.yearData.yearly_target ?
                        in_range ? 'Target Uncertain' : 'Off Target'
                      : 'On Target'}</h2>

                      { revenue_forecast < this.props.yearData.yearly_target ?
                        in_range?
                          <p>It's going to be tight to meet your annual goal of {this.props.yearData.yearly_target_formatted}.
                          We estimate your total annual revenue will be somewhere between {annual_estimate_low_range_string} and {annual_estimate_high_range_string}.</p>
                        :
                          <p>We don't think you'll meet your annual goal of {this.props.yearData.yearly_target_formatted} as you're
                          averaging {this.props.yearData.monthly_average_revenue_formatted}/month. To get back on track,
                          you need to be earning {this.props.yearData.amount_required_each_month_to_now_hit_target_formatted}/month going forward.</p>
                      :
                        <p>You’re on target to meet your annual goal of {this.props.yearData.yearly_target_formatted} and
                        are averaging {this.props.yearData.monthly_average_revenue_formatted}/month.
                        If you keep this up, we estimate your total annual revenue will be {annual_estimate_low_range_string} – {annual_estimate_high_range_string}.</p>
                      }

                    </div>

                    <div className="data__right">

                      <h3>Risks</h3>

                      { risks.revenue.length > 0 ?
                        <ul className="issue">
                          {risks.revenue.map((item, key) =>
                            <li key={key}>
                              <HelpTooltip message={item.tooltip} position={'top'} size={'large'}><ErrorIcon /></HelpTooltip>
                              <span>{ item.title }</span>
                            </li>
                          )}
                        </ul>
                      :
                        <ul className="positive">
                          <li>
                            <PositiveIcon />
                            <span>None, looks good</span>
                          </li>
                        </ul>
                      }

                    </div>

                    <div className="data__full">

                      <header>
                        <div className="status"></div>
                        <div>Estimated Total Annual Revenue<br/>{annual_estimate_low_range_string} – {annual_estimate_high_range_string}</div>
                        <div className="legend">
                          <div><span className="dot" style={{ backgroundColor: '#12C357' }}></span>Target</div>
                          <div><span className="dot" style={{ backgroundColor: '#D0D2D5'}}></span>Forecast</div>
                          <div><span className="dot" style={{ backgroundColor: '#0477F8' }}></span>Cumulative Total</div>
                        </div>
                      </header>

                      <div className="chart__revenue">
                        <ResponsiveContainer>
                          <ComposedChart
                            width={500}
                            height={400}
                            data={revenue_data}>
                            <ReferenceLine x={this.props.monthData.short_name} stroke="#D0D2D5" isFront={false} />
                            <XAxis type="category" dataKey="month" tickMargin={5} axisLine={false} tickLine={false} minTickGap={0} allowDataOverflow={false} interval={'preserveStartEnd'} />
                            <Line isAnimationActive={false} type="monotone" dataKey="target" stroke="#12C357" strokeWidth={4} dot={false} />
                            <Line isAnimationActive={false} type="monotone" dataKey="forecast" stroke="#D0D2D5" strokeWidth={4} dot={false} />
                            <Line isAnimationActive={false} type="monotone" dataKey="earned" stroke="#0477F8" strokeWidth={4} dot={false} />
                            <Tooltip content={<CustomTooltip currency={this.props.currentUser.currency}/>}/>
                          </ComposedChart>
                        </ResponsiveContainer>
                      </div>

                    </div>

                    { this.props.yearData.unscheduled_projects.map((item, key) =>
                      <div className="pending" key={key}>
                        <PriceIcon />
                        <span>You still need to schedule { this.formatPrice(item.remaining) } for the { item.title } project.</span>
                      </div>
                    )}

                  </div>

                  <div className="data">

                    <div className="data__left">

                      <h3>Productivity</h3>

                      <h2>{ risks.productivity.length > 0 ? 'Needs Improving' : 'Excellent'}</h2>

                      { risks.productivity.length > 1 ?
                        <p>You’ve only worked {this.props.yearData.total_productivity_percentage}% of the days available to work so far this year
                        ({this.props.yearData.number_of_days_worked} out of {this.props.yearData.total_workable_days_to_date}). We recommend finding some new
                        clients to help fill this gap in the coming months.</p>
                      :
                        <p>You’ve worked over {this.props.yearData.total_productivity_percentage}% of the days available so far this year
                         and have worked planned for another {this.props.yearData.total_productivity_forecast_percentage}%.</p>
                      }

                    </div>

                    <div className="data__right">

                      <h3>Risks</h3>

                      { risks.productivity.length > 0 ?
                        <ul className="issue">
                          {risks.productivity.map((item, key) =>
                            <li key={key}>
                              <HelpTooltip message={item.tooltip} position={'top'} size={'large'}><ErrorIcon /></HelpTooltip>
                              <span>{ item.title }</span>
                            </li>
                          )}
                        </ul>
                      :
                        <ul className="positive">
                          <li>
                            <PositiveIcon />
                            <span>None, looks good</span>
                          </li>
                        </ul>
                      }

                    </div>

                    <div className="data__full">

                      <div className="chart__productivity">
                      {this.props.yearData.month_breakdown.map((item, key) =>
                        <HelpTooltip
                          key={key}
                          message={`${item.month_name} <br /> ${item.productivity}% Productivity`} position={'top'} size={'small'}>
                          <Link to={`/month/${item.month}/${item.year}`}>
                            <div
                              className={item.productivity > 60 ? 'above' : 'below'}>
                            </div>
                          </Link>
                        </HelpTooltip>
                      )}
                      </div>

                    </div>

                  </div>
                  </React.Fragment>
                )}

              </div>

            </section>

          </section>

        </React.Fragment>
      );
    } else {
      return (<div className="loading"><div className="loader"></div></div>)
    }
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(Home);

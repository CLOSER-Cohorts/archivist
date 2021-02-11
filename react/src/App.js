import React from 'react';
import { Switch, BrowserRouter as Router, Redirect, Route } from 'react-router-dom';

import routes from './routes'
import AuthRoute from './AuthRoute'
import Login from './pages/Login';
import Instruments from './pages/Instruments';
import InstrumentView from './pages/InstrumentView';
import InstrumentMap from './pages/InstrumentMap';
import InstrumentBuild from './pages/InstrumentBuild';
import InstrumentConstructBuild from './pages/InstrumentConstructBuild';
import InstrumentBuildCodeLists from './pages/InstrumentBuildCodeLists';
import InstrumentBuildQuestionItems from './pages/InstrumentBuildQuestionItems';
import InstrumentBuildQuestionGrids from './pages/InstrumentBuildQuestionGrids';
import InstrumentBuildResponseDomains from './pages/InstrumentBuildResponseDomains';
import NoMatch from './pages/NoMatch';
import RedirectFromState from './components/RedirectFromState';

import { MuiThemeProvider, createMuiTheme } from '@material-ui/core/styles';

const theme = createMuiTheme({
  palette: {
    primary: {
      main: '#009de6',
    },
    secondary: {
      main: '#652d90',
    },
    error: {
      main: '#eb008b',
    },
    warning: {
      main: '#eb008b',
    },
    info: {
      main: '#faaf40',
    },
    success: {
      main: '#37b34a',
    },
  }
});

const App = () => {

  return (
    <MuiThemeProvider theme={theme}>
      <Router>
       <div>
          <RedirectFromState />
          <Switch>
            <AuthRoute type="guest" exact path={routes.login} component={Login} />
            <Route
              exact
              path="/"
              render={() => {return ( <Redirect to={routes.instruments.all} />)}}
            />
            <AuthRoute type="private" exact path={routes.instruments.instrument.map.show} component={InstrumentMap} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.show} component={InstrumentBuild} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.show} component={InstrumentView} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.codeLists.all} component={InstrumentBuildCodeLists} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.codeLists.show} component={InstrumentBuildCodeLists} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.codeLists.new} component={InstrumentBuildCodeLists} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.questionItems.all} component={InstrumentBuildQuestionItems} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.questionItems.show} component={InstrumentBuildQuestionItems} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.questionItems.new} component={InstrumentBuildQuestionItems} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.questionGrids.all} component={InstrumentBuildQuestionGrids} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.questionGrids.show} component={InstrumentBuildQuestionGrids} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.questionGrids.new} component={InstrumentBuildQuestionGrids} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.responseDomains.all} component={InstrumentBuildResponseDomains} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.responseDomains.show} component={InstrumentBuildResponseDomains} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.responseDomains.new} component={InstrumentBuildResponseDomains} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.constructs.show} component={InstrumentConstructBuild} />
            <AuthRoute type="private" exact path={routes.instruments.all} component={Instruments} />
            <AuthRoute type="guest" component={NoMatch} />
          </Switch>
        </div>
      </Router>
    </MuiThemeProvider>
  )
}

export default App

import React from 'react';
import { Switch, BrowserRouter as Router, Redirect, Route } from 'react-router-dom';

import routes from './routes'
import AuthRoute from './AuthRoute'
import Login from './pages/Login';
import Instruments from './pages/Instruments';
import InstrumentMap from './pages/InstrumentMap';
import InstrumentBuild from './pages/InstrumentBuild';
import InstrumentBuildCodeLists from './pages/InstrumentBuildCodeLists';
import InstrumentBuildQuestionItems from './pages/InstrumentBuildQuestionItems';
import InstrumentBuildQuestionGrids from './pages/InstrumentBuildQuestionGrids';
import InstrumentBuildResponseDomains from './pages/InstrumentBuildResponseDomains';
import NoMatch from './pages/NoMatch';

const App = () => {

  return (
    <Router>
     <div>
        <Switch>
          <AuthRoute type="guest" exact path={routes.login} component={Login} />
          <Route
            exact
            path="/"
            render={() => {return ( <Redirect to={routes.instruments.all} />)}}
          />
          <AuthRoute type="private" exact path={routes.instruments.instrument.map.show} component={InstrumentMap} />
          <AuthRoute type="private" exact path={routes.instruments.instrument.build.show} component={InstrumentBuild} />
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
          <AuthRoute type="private" exact path={routes.instruments.all} component={Instruments} />
          <AuthRoute type="guest" component={NoMatch} />
        </Switch>
      </div>
    </Router>
  )
}

export default App

import React from 'react';
import { Switch, BrowserRouter as Router } from 'react-router-dom';

import routes from './routes'
import AuthRoute from './AuthRoute'
import Login from './pages/Login';
import Instruments from './pages/Instruments';
import InstrumentMap from './pages/InstrumentMap';
import InstrumentBuild from './pages/InstrumentBuild';
import InstrumentBuildCodeLists from './pages/InstrumentBuildCodeLists';
import NoMatch from './pages/NoMatch';

const App = () => {

  return (
    <Router>
     <div>
        <Switch>
          <AuthRoute type="guest" exact path={routes.login} component={Login} />
          <AuthRoute type="private" exact path={routes.instruments.all} component={Instruments} />
          <AuthRoute type="private" exact path={routes.instruments.instrument.map.show} component={InstrumentMap} />
          <AuthRoute type="private" exact path={routes.instruments.instrument.build.show} component={InstrumentBuild} />
          <AuthRoute type="private" exact path={routes.instruments.instrument.build.codeLists.all} component={InstrumentBuildCodeLists} />
          <AuthRoute type="private" exact path={routes.instruments.instrument.build.codeLists.show} component={InstrumentBuildCodeLists} />
          <AuthRoute type="private" exact path={routes.instruments.instrument.build.codeLists.new} component={InstrumentBuildCodeLists} />
          <AuthRoute type="guest" component={NoMatch} />
        </Switch>
      </div>
    </Router>
  )
}

export default App

import React from 'react';
import { Switch, BrowserRouter as Router, Redirect, Route } from 'react-router-dom';

import routes from './routes'
import AuthRoute from './AuthRoute'
import Login from './pages/Login';
import AdminImport from './pages/AdminImport';
import AdminImportView from './pages/AdminImportView';
import AdminImports from './pages/AdminImports';
import AdminInstrumentImportMappings from './pages/AdminInstrumentImportMappings';
import AdminInstrumentImportMappingView from './pages/AdminInstrumentImportMappingView';
import AdminDatasetImportMappings from './pages/AdminDatasetImportMappings';
import AdminDatasetImportMappingView from './pages/AdminDatasetImportMappingView';
import AdminInstruments from './pages/AdminInstruments';
import AdminDatasets from './pages/AdminDatasets';
import Instruments from './pages/Instruments';
import Datasets from './pages/Datasets';
import DatasetView from './pages/DatasetView';
import InstrumentView from './pages/InstrumentView';
import InstrumentNew from './pages/InstrumentNew';
import InstrumentEdit from './pages/InstrumentEdit';
import InstrumentMap from './pages/InstrumentMap';
import InstrumentBuild from './pages/InstrumentBuild';
import InstrumentCcConditions from './pages/InstrumentCcConditions';
import InstrumentCcLoops from './pages/InstrumentCcLoops';
import InstrumentCcQuestions from './pages/InstrumentCcQuestions';
import InstrumentCcSequences from './pages/InstrumentCcSequences';
import InstrumentCcStatements from './pages/InstrumentCcStatements';
import InstrumentConstructBuild from './pages/InstrumentConstructBuild';
import InstrumentBuildCodeLists from './pages/InstrumentBuildCodeLists';
import InstrumentBuildQuestionItems from './pages/InstrumentBuildQuestionItems';
import InstrumentBuildQuestionGrids from './pages/InstrumentBuildQuestionGrids';
import InstrumentBuildResponseDomains from './pages/InstrumentBuildResponseDomains';
import NoMatch from './pages/NoMatch';
import RedirectFromState from './components/RedirectFromState';

import { MuiThemeProvider, createMuiTheme } from '@material-ui/core/styles';

const theme = createMuiTheme({
  props: {
    // Name of the component ⚛️
    MuiButtonBase: {
      // The properties to apply
      disableRipple: true, // No more ripple, on the whole application 💣!
    },
  },
  palette: {
    primary: {
      main: '#009de6',
    },
    secondary: {
      main: '#652d90',
    },
    admin: {
      main: '#37b34a',
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
            <AuthRoute type="private" exact path={routes.instruments.new} component={InstrumentNew} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.edit} component={InstrumentEdit} />
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
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.ccConditions} component={InstrumentCcConditions} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.ccLoops} component={InstrumentCcLoops} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.ccQuestions} component={InstrumentCcQuestions} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.ccSequences} component={InstrumentCcSequences} />
            <AuthRoute type="private" exact path={routes.instruments.instrument.build.ccStatements} component={InstrumentCcStatements} />
            <AuthRoute type="private" exact path={routes.instruments.all} component={Instruments} />
            <AuthRoute type="private" exact path={routes.datasets.all} component={Datasets} />
            <AuthRoute type="private" exact path={'/datasets/:dataset_id'} component={DatasetView} />
            <AuthRoute type="private" exact path={routes.admin.datasets.all} component={AdminDatasets} />
            <AuthRoute type="private" exact path={routes.admin.import} component={AdminImport} />
            <AuthRoute type="private" exact path={routes.admin.imports.all} component={AdminImports} />
            <AuthRoute type="private" exact path={routes.admin.imports.show} component={AdminImportView} />
            <AuthRoute type="private" exact path={routes.admin.instruments.all} component={AdminInstruments} />
            <AuthRoute type="private" exact path={routes.admin.instruments.importMappings} component={AdminInstrumentImportMappings} />
            <AuthRoute type="private" exact path={routes.admin.instruments.importMapping} component={AdminInstrumentImportMappingView} />
            <AuthRoute type="private" exact path={routes.admin.datasets.importMappings} component={AdminDatasetImportMappings} />
            <AuthRoute type="private" exact path={routes.admin.datasets.importMapping} component={AdminDatasetImportMappingView} />
            <AuthRoute type="guest" component={NoMatch} />
          </Switch>
        </div>
      </Router>
    </MuiThemeProvider>
  )
}

export default App

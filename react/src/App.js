import React from 'react';
import { Routes, BrowserRouter as Router, Navigate, Route } from 'react-router-dom';
import routes from './routes'
import AuthRoute from './AuthRoute'
import Login from './pages/Login';
import Signup from './pages/Signup';
import ForgottenPassword from './pages/ForgottenPassword';
import ResetPassword from './pages/ResetPassword';
import AdminImport from './pages/AdminImport';
import AdminImportView from './pages/AdminImportView';
import AdminImports from './pages/AdminImports';
import AdminExportView from './pages/AdminExportView';
import AdminExports from './pages/AdminExports';
import AdminInstrumentImportMappings from './pages/AdminInstrumentImportMappings';
import AdminInstrumentImportMappingView from './pages/AdminInstrumentImportMappingView';
import AdminDatasetImportMappings from './pages/AdminDatasetImportMappings';
import AdminDatasetImportMappingView from './pages/AdminDatasetImportMappingView';
import AdminUsers from './pages/AdminUsers';
import AdminUserEdit from './pages/AdminUserEdit';
import AdminInstruments from './pages/AdminInstruments';
import AdminInstrumentExports from './pages/AdminInstrumentExports';
import AdminInstrumentView from './pages/AdminInstrumentView';
import AdminInstrumentEdit from './pages/AdminInstrumentEdit';
import AdminInstrumentDatasetLink from './pages/AdminInstrumentDatasetLink';
import AdminDatasets from './pages/AdminDatasets';
import AdminDatasetView from './pages/AdminDatasetView';
import Instruments from './pages/Instruments';
import Datasets from './pages/Datasets';
import DatasetView from './pages/DatasetView';
import DatasetEdit from './pages/DatasetEdit';
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
      disableRipple: true // No more ripple, on the whole application 💣!
    }
  },
  palette: {
    primary: {
      main: '#009de6'
    },
    secondary: {
      main: '#652d90'
    },
    admin: {
      main: '#37b34a'
    },
    error: {
      main: '#eb008b'
    },
    warning: {
      main: '#eb008b'
    },
    info: {
      main: '#faaf40'
    },
    success: {
      main: '#37b34a'
    }
  }
});

const App = () => {
  const routeConfig = [
    { path: routes.signup, type: "guest", element: <Signup /> },
    { path: routes.login, type: "guest", element: <Login /> },
    { path: routes.forgotten_password, type: "guest", element: <ForgottenPassword /> },
    { path: routes.reset_password, type: "guest", element: <ResetPassword /> },
    { path: routes.instruments.all, type: "reader", element: <Instruments /> },
    // Editor Routes
    { path: routes.instruments.instrument.map.show, type: "editor", element: <InstrumentMap /> },
    { path: routes.instruments.instrument.build.show, type: "editor", element: <InstrumentBuild /> },
    { path: routes.instruments.new, type: "editor", element: <InstrumentNew /> },
    { path: routes.instruments.instrument.edit, type: "editor", element: <InstrumentEdit /> },
    { path: routes.instruments.instrument.build.codeLists.all, type: "editor", element: <InstrumentBuildCodeLists /> },
    { path: routes.instruments.instrument.build.codeLists.show, type: "editor", element: <InstrumentBuildCodeLists /> },
    { path: routes.instruments.instrument.build.codeLists.new, type: "editor", element: <InstrumentBuildCodeLists /> },
    { path: routes.instruments.instrument.build.questionItems.all, type: "editor", element: <InstrumentBuildQuestionItems /> },
    { path: routes.instruments.instrument.build.questionItems.show, type: "editor", element: <InstrumentBuildQuestionItems /> },
    { path: routes.instruments.instrument.build.questionItems.new, type: "editor", element: <InstrumentBuildQuestionItems /> },
    { path: routes.instruments.instrument.build.questionGrids.all, type: "editor", element: <InstrumentBuildQuestionGrids /> },
    { path: routes.instruments.instrument.build.questionGrids.show, type: "editor", element: <InstrumentBuildQuestionGrids /> },
    { path: routes.instruments.instrument.build.questionGrids.new, type: "editor", element: <InstrumentBuildQuestionGrids /> },
    { path: routes.instruments.instrument.build.responseDomains.all, type: "editor", element: <InstrumentBuildResponseDomains /> },
    { path: routes.instruments.instrument.build.responseDomains.show, type: "editor", element: <InstrumentBuildResponseDomains /> },
    { path: routes.instruments.instrument.build.responseDomains.new, type: "editor", element: <InstrumentBuildResponseDomains /> },
    { path: routes.instruments.instrument.build.constructs.show, type: "editor", element: <InstrumentConstructBuild /> },
    { path: routes.instruments.instrument.build.ccConditions, type: "editor", element: <InstrumentCcConditions /> },
    { path: routes.instruments.instrument.build.ccLoops, type: "editor", element: <InstrumentCcLoops /> },
    { path: routes.instruments.instrument.build.ccQuestions, type: "editor", element: <InstrumentCcQuestions /> },
    { path: routes.instruments.instrument.build.ccSequences, type: "editor", element: <InstrumentCcSequences /> },
    { path: routes.instruments.instrument.build.ccStatements, type: "editor", element: <InstrumentCcStatements /> },
    // Reader Routes
    { path: routes.instruments.instrument.show, type: "reader", element: <InstrumentView /> },
    { path: routes.instruments.all, type: "reader", element: <Instruments /> },
    { path: routes.datasets.all, type: "reader", element: <Datasets /> },
    { path: "/datasets/:dataset_id", type: "reader", element: <DatasetView /> },
    { path: routes.datasets.dataset.edit, type: "editor", element: <DatasetEdit /> },
    // Admin Routes
    { path: routes.admin.datasets.all, type: "admin", element: <AdminDatasets /> },
    { path: routes.admin.datasets.dataset.show, type: "admin", element: <AdminDatasetView /> },
    { path: routes.admin.import, type: "admin", element: <AdminImport /> },
    { path: routes.admin.imports.all, type: "admin", element: <AdminImports /> },
    { path: routes.admin.imports.show, type: "admin", element: <AdminImportView /> },
    { path: routes.admin.exports.all, type: "admin", element: <AdminExports /> },
    { path: routes.admin.exports.show, type: "admin", element: <AdminExportView /> },
    { path: routes.admin.instruments.instrument.edit, type: "admin", element: <AdminInstrumentEdit /> },
    { path: routes.admin.instruments.instrument.show, type: "admin", element: <AdminInstrumentView /> },
    { path: routes.admin.users.all, type: "admin", element: <AdminUsers /> },
    { path: routes.admin.users.user.edit, type: "admin", element: <AdminUserEdit /> },
    { path: routes.admin.instruments.all, type: "admin", element: <AdminInstruments /> },
    { path: routes.admin.instruments.exports, type: "admin", element: <AdminInstrumentExports /> },
    { path: routes.admin.instruments.instrument.datasets, type: "admin", element: <AdminInstrumentDatasetLink /> },
    { path: routes.admin.instruments.importMappings, type: "admin", element: <AdminInstrumentImportMappings /> },
    { path: routes.admin.instruments.importMapping, type: "admin", element: <AdminInstrumentImportMappingView /> },
    { path: routes.admin.datasets.importMappings, type: "admin", element: <AdminDatasetImportMappings /> },
    { path: routes.admin.datasets.importMapping, type: "admin", element: <AdminDatasetImportMappingView /> },
    { path: "/", element: <Navigate to={routes.instruments.all} />, noAuth: true },
    { path: "*", element: <NoMatch />, noAuth: true }
  ];

  return (     
    <MuiThemeProvider theme={theme}>
      <Router>
       <div>
          <RedirectFromState />
          <Routes>
            {routeConfig.map(({ path, type, element, noAuth }) => (
              <Route
                key={path}
                path={path}
                element={
                  noAuth ? (
                    element
                  ) : (
                    <AuthRoute type={type}>
                      {element}
                    </AuthRoute>
                  )
                }
              />
            ))}
          </Routes>
        </div>
      </Router>
    </MuiThemeProvider>
  )
}

export default App

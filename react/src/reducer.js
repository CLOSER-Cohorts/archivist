import auth from './reducers/auth';
import { combineReducers } from 'redux';
import common from './reducers/common';
import home from './reducers/home';
import clients from './reducers/clients';
import projects from './reducers/projects';
import tasks from './reducers/tasks';
import settings from './reducers/settings';
import schedule from './reducers/schedule';
import months from './reducers/months';
import years from './reducers/years';
import admin_users from './reducers/admin_users';
import { connectRouter } from 'connected-react-router'

export default (history) => combineReducers({
  auth,
  common,
  home,
  settings,
  schedule,
  clients,
  projects,
  tasks,
  months,
  years,
  admin_users,
  router: connectRouter(history),
});

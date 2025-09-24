import './tailwind.css';
import React from 'react';
import ReactDOM from 'react-dom/client'; // Use 'react-dom/client' for createRoot
import { Provider } from 'react-redux';
import App from './App';
import Store from './components/Store';
import * as serviceWorker from './serviceWorker';
import { createConsumer } from '@rails/actioncable';

// ActionCable consumer setup - initialized once at app root
const cable_url = process.env.REACT_APP_API_HOST 
  ? process.env.REACT_APP_API_HOST.replace(/^http/, 'ws') + '/cable'
  : 'ws://localhost:3001/cable';

window.ActionCableConsumer = createConsumer(cable_url);

// Get the root DOM node
const rootElement = document.getElementById('root');

// Create a root
const root = ReactDOM.createRoot(rootElement);

// Render your application
root.render(
  <Provider store={Store}>
    <App />
  </Provider>
);

// Service worker setup (optional)
serviceWorker.unregister();
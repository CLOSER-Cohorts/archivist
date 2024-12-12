import './tailwind.css';
import React from 'react';
import ReactDOM from 'react-dom/client'; // Use 'react-dom/client' for createRoot
import { Provider } from 'react-redux';
import App from './App';
import Store from './components/Store';
import * as serviceWorker from './serviceWorker';

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
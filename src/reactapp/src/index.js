import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';
import { FluentProvider, teamsLightTheme } from "@fluentui/react-components";
import { Providers } from '@microsoft/mgt-element';
import { Msal2Provider } from '@microsoft/mgt-msal2-provider';
import { msalConfig } from "./authConfig"

Providers.globalProvider = new Msal2Provider({
    clientId: msalConfig.clientId,
    scopes: ['Agreement.Read.All', 'CrossTenantInformation.ReadBasic.All', 'Directory.Read.All', 'Policy.Read.All', 'User.Read'],
    loginType: 'redirect',
});

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
    <FluentProvider theme={teamsLightTheme}>
        <App />
    </FluentProvider>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();

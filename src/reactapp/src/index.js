import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';
import { FluentProvider, teamsDarkTheme, teamsLightTheme, webDarkTheme, webLightTheme } from "@fluentui/react-components";
import { Providers } from '@microsoft/mgt-element';
import { Msal2Provider } from '@microsoft/mgt-msal2-provider';
import { msalConfig } from "./authConfig"

Providers.globalProvider = new Msal2Provider({
    clientId: msalConfig.clientId,
    scopes: 
        [
            'Agreement.Read.All', 'CrossTenantInformation.ReadBasic.All', 'Directory.Read.All', 'Policy.Read.All', 'User.Read', 'DeviceManagementServiceConfig.Read.All',
            'DeviceManagementConfiguration.Read.All', 'DeviceManagementRBAC.Read.All', 'DeviceManagementConfiguration.Read.All', 'DeviceManagementApps.Read.All',
            'RoleAssignmentSchedule.Read.Directory','RoleEligibilitySchedule.Read.Directory', 'PrivilegedEligibilitySchedule.Read.AzureADGroup'
        ],
    loginType: 'redirect',
});

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
    <FluentProvider theme={webLightTheme}>
        <App />
    </FluentProvider>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();

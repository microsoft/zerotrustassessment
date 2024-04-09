export const apiConfig = {
  apiEndPoint: "",
};

export const msalConfig = {
  auth: {
    clientId: "e7dfcbb6-fe86-44a2-b512-8d361dcc3d30",
  },
};

export const loginRequest = {
  scopes: [
    "Agreement.Read.All",
    "CrossTenantInformation.ReadBasic.All",
    "Directory.Read.All",
    "Policy.Read.All",
    "User.Read",
    "DeviceManagementServiceConfig.Read.All",
    "DeviceManagementConfiguration.Read.All",
    "DeviceManagementRBAC.Read.All",
    "DeviceManagementConfiguration.Read.All",
    "DeviceManagementApps.Read.All",
    "RoleAssignmentSchedule.Read.Directory",
    "RoleEligibilitySchedule.Read.Directory",
    "PrivilegedEligibilitySchedule.Read.AzureADGroup",
  ],
};

export const envConfig = {
  envName: "[Dev]",
};

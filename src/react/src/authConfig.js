export const apiConfig = {
  apiEndPoint: "",
};

export const msalConfig = {
  auth: {
    clientId: "df2798fc-2aed-4c3a-98ae-1776949480c4",
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

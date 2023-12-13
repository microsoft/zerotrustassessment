export const apiConfig = {
  apiEndPoint: "",
};

export const msalConfig = {
  auth: {
    clientId: "be58d912-b9d5-41a0-8b56-779409e017b8",
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

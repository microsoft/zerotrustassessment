using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;

namespace ZeroTrustAssessment.DocumentGenerator.Sheets;

public class SheetAssessmentIdentity : SheetBase
{
    private const string RoleIdGlobalAdmin = "62e90394-69f5-4237-9190-012177145e10";
    public SheetAssessmentIdentity(IWorksheet sheet, GraphData graphData) : base(sheet, graphData)
    {
    }

    public void Generate()
    {
        WorkloadChecks();
        TenantAppManagementPolicy();
        GlobalAdminPhishingResistantAuthStrength();
        BasicMfaUsageInsteadOfAuthStrength();
        SecureRegistrationOfSecurityInfo();
        CloudOnlyCloudPrivilege();
        RegistrationCampaign();
        PhishingResistantAuthMethods();
    }

    private void WorkloadChecks()
    {
        var hasWorkloadPolicies = _graphData.ConditionalAccessPolicies.Any(
            x => x?.Conditions?.ClientApplications != null && x?.Conditions?.ClientApplications?.IncludeServicePrincipals?.Count > 0);

        var result = hasWorkloadPolicies ? AssessmentValue.Completed : AssessmentValue.NotStartedP1;
        SetValue("I00001_Workload_Exists", result);
    }

    private void TenantAppManagementPolicy()
    {
        var appPolicy = _graphData.TenantAppManagementPolicy;
        var hasTenantPolicy = appPolicy != null && appPolicy.IsEnabled == true;

        var result = hasTenantPolicy ? AssessmentValue.Completed : AssessmentValue.NotStartedP1;
        SetValue("I00002_Workload_TenantAppMgmtPolicy", result);
    }

    private void GlobalAdminPhishingResistantAuthStrength()
    {
        //TODO Check if auth strength is actually a phishing reistant auth strength

        var globalAdminPoliciesWithMfa = _graphData.ConditionalAccessPolicies.Any(
            x => x?.Conditions?.Users?.IncludeRoles?.Contains(RoleIdGlobalAdmin) == true &&
                x?.GrantControls?.AuthenticationStrength != null);

        var result = globalAdminPoliciesWithMfa ? AssessmentValue.Completed : AssessmentValue.NotStartedP1;
        SetValue("I00003_GlobalAdminPhishingResistantAuthStrength", result);
    }

    private void BasicMfaUsageInsteadOfAuthStrength()
    {
        var basicMfaInUse = _graphData.ConditionalAccessPolicies.Any(
            x => x?.GrantControls?.BuiltInControls?.Contains(ConditionalAccessGrantControl.Mfa) == true);

        var resultNoAuthStrength = basicMfaInUse ? AssessmentValue.NotStartedP2 : AssessmentValue.Completed;

        var hasAuthStrength = _graphData.ConditionalAccessPolicies.Any(
            x => x?.GrantControls?.AuthenticationStrength != null);

        var resultBasicMfa = basicMfaInUse || hasAuthStrength ? AssessmentValue.Completed : AssessmentValue.Completed;

        SetValue("I00004_BasicMfaUsageInsteadOfAuthStrength", resultNoAuthStrength);
        SetValue("I00005_BasicMfaInUse", resultBasicMfa);
    }

    private void SecureRegistrationOfSecurityInfo()
    {
        var hasSecurityInfo = _graphData.ConditionalAccessPolicies.Any(
            x => x?.Conditions?.Applications?.IncludeUserActions?.Contains("urn:user:registersecurityinfo") == true);

        var hasSecurityInfoAndDevice = _graphData.ConditionalAccessPolicies.Any(
            x => x?.Conditions?.Applications?.IncludeUserActions?.Contains("urn:user:registersecurityinfo") == true &&
            (x?.GrantControls?.BuiltInControls?.Contains(ConditionalAccessGrantControl.CompliantDevice) == true ||
            x?.GrantControls?.BuiltInControls?.Contains(ConditionalAccessGrantControl.DomainJoinedDevice) == true)
            );

        var result = hasSecurityInfoAndDevice ? AssessmentValue.Completed :
                       hasSecurityInfo ? AssessmentValue.NotStartedP1 : AssessmentValue.NotStartedP0;

        SetValue("I00006_SecureRegistrationOfSecurityInfo", result);
    }

    private void CloudOnlyCloudPrivilege()
    {
        //TODO check entitlements as well
        var globalAdminRoles = _graphData.RoleAssignments.Where(x => x?.RoleDefinitionId == RoleIdGlobalAdmin);
        var hasGlobalAdminSyncedAccounts = HasSyncedAccounts(globalAdminRoles);
        var hasPrivilegedRolesSyncedAccounts = false; //todo lookup other roles
        var result = hasGlobalAdminSyncedAccounts ? AssessmentValue.NotStartedP0 :
                       hasPrivilegedRolesSyncedAccounts ? AssessmentValue.NotStartedP1 : AssessmentValue.Completed;

        SetValue("I00007_CloudOnlyCloudPrivilege", result);
    }

    private void RegistrationCampaign()
    {
        var authPolicy = _graphData.AuthenticationMethodsPolicy;

        var result = authPolicy != null &&
            authPolicy.RegistrationEnforcement?.AuthenticationMethodsRegistrationCampaign?.State == AdvancedConfigState.Enabled
            ? AssessmentValue.Completed : AssessmentValue.NotStartedP1;

        SetValue("I00008_RegistrationCampaign", result);
    }


    private void PhishingResistantAuthMethods()
    {
        var authPolicy = _graphData.AuthenticationMethodsPolicy;

        bool hasFido2 = false;
        bool hasCba = false;
        if (authPolicy?.AuthenticationMethodConfigurations != null)
        {
            foreach (var method in authPolicy.AuthenticationMethodConfigurations)
            {
                if (method is Fido2AuthenticationMethodConfiguration fido2)
                {
                    if (method.State == AuthenticationMethodState.Enabled)
                    {
                        hasFido2 = true;
                    }
                }
                else if (method is X509CertificateAuthenticationMethodConfiguration cba)
                {
                    if (method.State == AuthenticationMethodState.Enabled)
                    {
                        hasCba = true;
                    }
                }
            }
        }
        var result = AssessmentValue.Completed;
        if (!hasFido2 && !hasCba)
        {
            result = AssessmentValue.NotStartedP1;
        }
        else if (!hasFido2)
        {
            result = AssessmentValue.NotStartedP2;
        }

        SetValue("I00009_PhishingResistantAuthMethods", result);
    }

    private bool HasSyncedAccounts(IEnumerable<UnifiedRoleAssignment> roleAssignments)
    {
        //TODO Expand if group found
        foreach (var roleAssign in roleAssignments)
        {
            if (roleAssign.Principal is User user)
            {
                if (user.OnPremisesSyncEnabled == true) return true;
            }
        }
        return false;
    }
}
using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;

namespace ZeroTrustAssessment.DocumentGenerator.Sheets;

public class SheetAssessmentIdentity : SheetBase
{
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
        var globalAdminRoleId = "62e90394-69f5-4237-9190-012177145e10";

        var globalAdminPoliciesWithMfa = _graphData.ConditionalAccessPolicies.Any(
            x => x?.Conditions?.Users?.IncludeRoles?.Contains(globalAdminRoleId) == true &&
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
            x =>  x?.GrantControls?.AuthenticationStrength != null);

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
            x?.GrantControls?.BuiltInControls?.Contains(ConditionalAccessGrantControl.DomainJoinedDevice) == true )
            );

        var result = hasSecurityInfoAndDevice ? AssessmentValue.Completed : 
                       hasSecurityInfo ? AssessmentValue.NotStartedP1 : AssessmentValue.NotStartedP0;

        SetValue("I00006_SecureRegistrationOfSecurityInfo", result);
    }
}
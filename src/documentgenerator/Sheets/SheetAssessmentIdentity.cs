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
}
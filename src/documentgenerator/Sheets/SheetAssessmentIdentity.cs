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
}
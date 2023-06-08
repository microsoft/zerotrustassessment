using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;

namespace ZeroTrustAssessment.DocumentGenerator.Sheets;

public class SheetConfigDevice : SheetBase
{
    public SheetConfigDevice(IWorksheet sheet, GraphData graphData) : base(sheet, graphData)
    {
    }

    public void Generate()
    {
        MdmWindowsEnrollment();
    }

    private void MdmWindowsEnrollment()
    {
        if (_graphData.MobilityManagementPolicies == null)
        {
            SetValue("Table_WindowsEnrollment", "Not configured");
            return;
        }

        var startColumn = _sheet.Range["Table_WindowsEnrollment"].Column;
        var startRow = _sheet.Range["Table_WindowsEnrollment"].Row;

        var row = startRow;
        var rowCount = _graphData.MobilityManagementPolicies.Count;
        _sheet.InsertRow(startRow, rowCount);
        foreach (var policy in _graphData.MobilityManagementPolicies.OrderByDescending(x => x.AppliesTo).ThenBy(x => x.DisplayName))
        {
            _sheet.SetText(row, startColumn, "MDM");
            _sheet.SetText(row, startColumn + 1, policy.DisplayName);
            _sheet.SetText(row, startColumn + 6, GetAppliesToName(policy.AppliesTo));
            var groupName = policy.AppliesTo == PolicyScope.Selected && policy.IncludedGroups != null ?
                string.Join(", ", policy.IncludedGroups.Select(x => x.DisplayName)) : "N/A";
            _sheet.SetText(row, startColumn + 8, groupName);
            row++;
        }
    }

    private static string GetAppliesToName(PolicyScope? scope)
    {
        if (scope == null) return string.Empty;

        return scope switch
        {
            PolicyScope.None => "None",
            PolicyScope.All => "All",
            PolicyScope.Selected => "Some",
            _ => string.Empty,
        };
    }
}
using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;

namespace ZeroTrustAssessment.DocumentGenerator.Sheets;
public class SheetBase
{
    protected readonly IWorksheet _sheet;
    protected readonly GraphData _graphData;

    protected enum AssessmentValue
    {
        NotStarted,
        NotStartedP0,
        NotStartedP1,
        NotStartedP2,
        InProgress,
        Completed
    }

    public SheetBase(IWorksheet sheet, GraphData graphData)
    {
        _sheet = sheet;
        _graphData = graphData;
    }
    protected void SetValue(string rangeName, string value)
    {
        _sheet.Range[rangeName].Text = value;
    }
    
    protected void SetValue(string rangeName, AssessmentValue assessmentValue)
    {
        string value = string.Empty;
        switch(assessmentValue){
            case AssessmentValue.NotStarted:
                value = "☉ Not started";
                break;
            case AssessmentValue.NotStartedP0:
                value = "☉ Not started (P0)";
                break;
            case AssessmentValue.NotStartedP1:
                value = "☉ Not started (P1)";
                break;
            case AssessmentValue.NotStartedP2:
                value = "☉ Not started (P2)";
                break;
            case AssessmentValue.InProgress:
                value = "▷ In progress";
                break;
            case AssessmentValue.Completed:
                value = "✓ Completed";
                break;
        }
        SetValue(rangeName, value);
    }
}
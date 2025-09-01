using Microsoft.Graph.Beta.Models;
using Microsoft.Graph.Beta.Models.TermStore;
using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;

namespace ZeroTrustAssessment.DocumentGenerator.Sheets;
public class SheetBase
{
    protected readonly IWorkbook _workbook;
    protected readonly IWorksheet _sheet;
    protected readonly GraphData _graphData;

    private int _totalChecks = 0;
    private int _currentScore = 0;


    public SheetBase(IWorkbook workbook, ZtSheets sheet, GraphData graphData)
    {
        _workbook = workbook;
        _sheet = GetWorksheet(sheet);
        _graphData = graphData;
    }

    private IWorksheet GetWorksheet(ZtSheets sheet)
    {
        return ZtWorkbook.GetWorksheet(_workbook, sheet);
    }

    protected enum AssessmentValue
    {
        NotStarted,
        NotStartedP0,
        NotStartedP1,
        NotStartedP2,
        InProgress,
        Completed
    }

    public enum AssessmentScore
    {
        NotEvaluated,
        NotDeployed,
        PartiallyDeployed,
        FullyDeployed
    }

    public AssessmentScore GetAssessmentScore()
    {
        var score = AssessmentScore.NotEvaluated;
        if (_totalChecks > 0)
        {
            var resultScore = GetAssessmentScoreValue();
            if (resultScore > 90)
            {
                score = AssessmentScore.FullyDeployed;
            }
            else if (resultScore > 50)
            {
                score = AssessmentScore.PartiallyDeployed;
            }
            else
            {
                score = AssessmentScore.NotDeployed;
            }
        }
        return score;
    }

    public int GetAssessmentScoreValue()
    {
        return (int)(((double)_currentScore / (double)_totalChecks) * 100);
    }

    protected void SetValue(string rangeName, string value)
    {
        _sheet.Range[rangeName].Text = value;
    }

    protected void SetValue(string rangeName, AssessmentValue assessmentValue)
    {
        _totalChecks++;
        string value = string.Empty;
        switch (assessmentValue)
        {
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
                _currentScore++;
                break;
        }
        SetValue(rangeName, value);
    }

    protected void ShowScore()
    {
        var score = GetAssessmentScore();
        var scoreValue = GetAssessmentScoreValue();
        _sheet.TextBoxes["asessScoreValue"].Text = $"{scoreValue}%";

        //ShowScore("assessScorePic", score);
    }

    protected void ShowScore(string imagePosition, AssessmentScore identityScore)
    {

        var scoreToCopy = identityScore switch
        {
            AssessmentScore.NotEvaluated => "ratingNotEvaluated",
            AssessmentScore.NotDeployed => "ratingLow",
            AssessmentScore.PartiallyDeployed => "ratingMedium",
            AssessmentScore.FullyDeployed => "ratingHigh",
            _ => "ratingNotEvaluated",
        };

        var picToCopy = GetWorksheet(ZtSheets.Home).Pictures[scoreToCopy];

        _sheet.Pictures[imagePosition].Picture = picToCopy.Picture;
    }
}
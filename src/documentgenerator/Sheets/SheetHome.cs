using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;

namespace ZeroTrustAssessment.DocumentGenerator.Sheets;

public class SheetHome : SheetBase
{
    public SheetHome(IWorksheet sheet, GraphData graphData) : base(sheet, graphData)
    {
    }

    public void Generate()
    {
        SetDocHeaderInfo();
    }

    private void SetDocHeaderInfo()
    {

        if (_graphData.Organization != null && _graphData.Organization.Count > 0)
        {
            var org = _graphData.Organization.First();

            var currentDate = DateTime.Now.ToString("dd MMM yyyy");
            _sheet.Range["HeaderTenantId"].Text = $"Tenant ID: {org.Id}";
            _sheet.Range["HeaderTitle"].Text = $"Zero Trust Assessment for {org.DisplayName}";
            _sheet.Range["HeaderAssessedOn"].Text = $"Assessment generated on {currentDate} by {_graphData?.Me?.DisplayName} ({_graphData?.Me?.UserPrincipalName})";
            _sheet.TextBoxes["txtIdentityStatus"].Text = "❌";

            SetBannerImage();
        }
    }

    private void SetBannerImage()
    {
        var logoBackgroundRectangle = _sheet.Shapes["bannerLogoBg"]; //Get the logo background

        if (_graphData.OrganizationLogo != null)
        {
            var picture = _sheet.Pictures.AddPicture(1, 1, _graphData.OrganizationLogo);
            picture.Top = 70;
            picture.Left = 1000;
            picture.AlternativeText = "Organization banner logo";
            //Position the background behind the logo
            logoBackgroundRectangle.Top = picture.Top - 10;
            logoBackgroundRectangle.Left = picture.Left - 20;
            logoBackgroundRectangle.Width = picture.Width + 40;
            logoBackgroundRectangle.Height = picture.Height + 20;
        }
        else {
            logoBackgroundRectangle.Remove(); //No logo image, remove the background as well
        }
    }
}


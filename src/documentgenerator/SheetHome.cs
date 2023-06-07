using System;
using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;

namespace ZeroTrustAssessment.DocumentGenerator
{
	public class SheetHome
	{
        private GraphData _graphData;
        private IWorksheet _sheet;

		public SheetHome(IWorksheet sheet, GraphData graphData)
		{
            _sheet = sheet;
            _graphData = graphData;
            
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
            var logoPh = _sheet.Shapes["bannerLogoBg"];

            if (_graphData.OrganizationLogo != null)
            {
                var picture = _sheet.Pictures.AddPicture(1, 1, _graphData.OrganizationLogo);
                picture.Top = 70;
                picture.Left = 1000;
                picture.AlternativeText = "Organization banner logo";
                logoPh.Top = picture.Top - 10;
                logoPh.Left = picture.Left - 20;
                logoPh.Width = picture.Width + 40;
                logoPh.Height = picture.Height + 20;


                var rectangle = _sheet.Shapes.AddAutoShapes(AutoShapeType.RoundedRectangle, 1, 1, 1, 1);
            }
            else {
                logoPh.Remove();
            }
        }
    }
}


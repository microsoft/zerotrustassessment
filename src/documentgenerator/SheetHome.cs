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
            }
        }
    }
}


using System;
using Microsoft.Graph.Beta.Models;
using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;

namespace ZeroTrustAssessment.DocumentGenerator
{
    public class ZtWorkbook
	{
		private IWorkbook _workbook;
		private GraphData _graphData;

        private enum Sheets
        {
            Home,
            IdentityWorkshop,
            DeviceWorkshop,
            IdentityConfig,
            DeviceConfig,
            IdentityAssessment,
            DeviceAssessment
        }

        private IWorksheet GetWorksheet(Sheets sheet)
        {
            return _workbook.Worksheets[(int)sheet];
        }

        public ZtWorkbook(IWorkbook workbook, GraphData graphData)
		{
			_workbook = workbook;
			_graphData = graphData;
		}

		public void GenerateDocument()
		{
            var sheetHome = new SheetHome(GetWorksheet(Sheets.Home), _graphData);

            sheetHome.Generate();
        }
    }
}
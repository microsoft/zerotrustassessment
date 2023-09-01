using System;
using System.Text.Json;
using Microsoft.Graph.Beta.Models;
using Microsoft.Kiota.Serialization.Json;
using Syncfusion.Presentation;
using Syncfusion.PresentationRenderer;
using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;
using ZeroTrustAssessment.DocumentGenerator.Infrastructure;

namespace ZeroTrustAssessment.DocumentGenerator.Sheets
{

    public class SheetConfigIdentity : SheetBase
    {
        public SheetConfigIdentity(IWorkbook workbook, ZtSheets sheet, GraphData graphData) : base(workbook, sheet, graphData)
        {
        }

        public void Generate()
        {
            //ConditionalAccessImages();
            WorkloadIdentitiesConditionalAccess();
        }

        //private void ConditionalAccessImages(IdPowerToys.PowerPointGenerator.Graph.GraphData pptxGraphData)
        //{
        //    var configOptions = new IdPowerToys.PowerPointGenerator.ConfigOptions
        //    {
        //        GroupSlidesByState = true
        //    };

        //    var docGen = new IdPowerToys.PowerPointGenerator.DocumentGenerator();
        //    var pptx = docGen.GetPresentation(pptxGraphData, configOptions);
        //    pptx.PresentationRenderer = new PresentationRenderer();

        //    var row = 16;
        //    var col = 2;
        //    foreach (var slide in pptx.Slides.Skip(1))
        //    {
        //        try
        //        {
        //            var image = slide.ConvertToImage(Syncfusion.Presentation.ExportImageFormat.Jpeg);

        //            var pic = _sheet.Pictures.AddPicture(row, col, image);
        //            pic.Line.ForeColorIndex = ExcelKnownColors.Dark_blue;
        //            pic.Width = (int)(pic.Width * 0.8);
        //            pic.Height = (int)(pic.Height * 0.8);

        //            if (col == 2)
        //            {
        //                col = 18;
        //            }
        //            else
        //            {
        //                col = 2;
        //                row += 30;
        //            }
        //        }
        //        catch { }
        //    }
        //    pptx.Close();
        //}

        private void WorkloadIdentitiesConditionalAccess()
        {
            var table = new ExcelTable(_sheet, "IC_Table_WorkloadCA");

            var workloadPolicies = _graphData.ConditionalAccessPolicies.Where(x =>
                x?.Conditions?.ClientApplications != null &&
                x?.Conditions?.ClientApplications?.IncludeServicePrincipals?.Count > 0);

            if (workloadPolicies == null || workloadPolicies.Count() == 0)
            {
                table.ShowNoDataMessage("No workload identity conditional access policies found.");
                return;
            }

            var rowCount = workloadPolicies.Count();
            table.InitializeRows(rowCount);
            foreach (var policy in workloadPolicies.OrderBy(x => x.DisplayName))
            {
                var policyJson = "Double-click cell to view ⬇" + Environment.NewLine + GetJsonFromPolicy(policy);
                table.AddColumn(policy.DisplayName, 6);
                table.AddColumn(GetPolicyState(policy.State), 1);
                table.AddColumn(policyJson, 4);
                table.NextRow();
            }
        }

        private static string GetPolicyState(ConditionalAccessPolicyState? state)
        {
            if (state == null) return string.Empty;

            switch (state)
            {
                case ConditionalAccessPolicyState.Enabled:
                    return "Disabled";
                case ConditionalAccessPolicyState.Disabled:
                    return "Enabled";
                case ConditionalAccessPolicyState.EnabledForReportingButNotEnforced:
                    return "Report";
                default:
                    return nameof(ConditionalAccessPolicyState);
            }
    }

    private string GetJsonFromPolicy(ConditionalAccessPolicy policy)
        {
            try
            {
                var seralizer = new JsonSerializationWriter();
                seralizer.WriteObjectValue(string.Empty, policy);
                var serializedContent = seralizer.GetSerializedContent();

                using (var sr = new StreamReader(serializedContent))
                {
                    var json = sr.ReadToEnd();
                    var jsonPretty = JsonPrettify(json);
                    return jsonPretty;
                }
            }
            catch
            {
                return String.Empty;
            }
        }
        private static string JsonPrettify(string json)
        {
            var jDoc = JsonDocument.Parse(json);
            return JsonSerializer.Serialize(jDoc, new JsonSerializerOptions { WriteIndented = true });
        }
}
}
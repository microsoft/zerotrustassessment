using System;
using Microsoft.Graph.Beta.Models;
using Syncfusion.Presentation;
using Syncfusion.PresentationRenderer;
using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;

namespace ZeroTrustAssessment.DocumentGenerator.Sheets
{
    public class SheetConfigIdentity : SheetBase
    {
        public SheetConfigIdentity(IWorksheet sheet, GraphData graphData) : base(sheet, graphData)
        {
        }

        public async Task GenerateAsync(IdPowerToys.PowerPointGenerator.Graph.GraphData pptxGraphData)
        {
            var configOptions = new IdPowerToys.PowerPointGenerator.ConfigOptions();
            configOptions.GroupSlidesByState = true;

            var docGen = new IdPowerToys.PowerPointGenerator.DocumentGenerator();
            var pptx = docGen.GetPresentation(pptxGraphData, configOptions);
            pptx.PresentationRenderer = new PresentationRenderer();

            var row = 10;
            var col = 2;
            foreach (var slide in pptx.Slides.Skip(1))
            {
                try
                {
                    var image = slide.ConvertToImage(Syncfusion.Presentation.ExportImageFormat.Jpeg);

                    var pic = _sheet.Pictures.AddPicture(row, col, image);
                    pic.Line.ForeColorIndex = ExcelKnownColors.Dark_blue;
                    pic.Width = (int)(pic.Width * 0.8);
                    pic.Height = (int)(pic.Height * 0.8);
                    
                    if (col == 2)
                    {
                        col = 18;
                    }
                    else
                    {
                        col = 2;
                        row += 30;
                    }
                }
                catch { }
            }
            pptx.Close();

        }
    }
}


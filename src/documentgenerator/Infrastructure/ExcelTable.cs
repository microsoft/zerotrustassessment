using Syncfusion.XlsIO;

namespace ZeroTrustAssessment.DocumentGenerator.Infrastructure;

public class ExcelTable
{
    private readonly IWorksheet _sheet;
    private readonly string _rangeName;

    private readonly int _startColumn;
    private readonly int _startRow;
    private int _currentRow;
    private int _currentColumn;

    public ExcelTable(IWorksheet sheet, string rangeName)
    {
        _sheet = sheet;
        _rangeName = rangeName;

        _startColumn = _sheet.Range[_rangeName].Column;
        _startRow = _sheet.Range[_rangeName].Row;
        _currentRow = _startRow;
        _currentColumn = _startColumn;
    }

    public void AddColumn(string? value)
    {
        AddColumn(value, 1);
    }
    public void AddColumn(string? value, int columnWidth)
    {
        _sheet.Range[_currentRow, _currentColumn].Text = value;
        if (columnWidth > 1) //Merge if needed
        {
            var range = $"{GetColumnName(_currentColumn)}{_currentRow}:{GetColumnName(_currentColumn + columnWidth - 1)}{_currentRow}";
            _sheet.Range[range].Merge();
        }
        _currentColumn += columnWidth;
    }

    public void ShowNoDataMessage()
    {
        SetValue("Not configured");
    }

    private void SetValue(string value)
    {
        _sheet.Range[_rangeName].Text = value;
    }

    public void NextRow()
    {
        _currentRow++;
        _currentColumn = _startColumn;
    }

    /// <summary>
    /// Inserts blank rows into the sheet to prepare for data to be written.
    /// </summary>
    /// <param name="rowCount"></param>
    public void InitializeRows(int rowCount)
    {
        _sheet.InsertRow(_startRow, rowCount - 1, ExcelInsertOptions.FormatAsAfter);
    }

    private static string GetColumnName(int index)
    {
        index--; //Change to be zero based
        const string letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

        var value = "";

        if (index >= letters.Length)
            value += letters[index / letters.Length - 1];

        value += letters[index % letters.Length];

        return value;
    }
}
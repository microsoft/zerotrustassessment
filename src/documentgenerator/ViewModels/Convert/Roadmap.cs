namespace ZeroTrustAssessment.DocumentGenerator.ViewModels.Convert;

public class Roadmap
{
    public Roadmap()
    {
        ValuePairs = new Dictionary<string, string>();
    }
    
    public string TenantId { get; set; }
    public Dictionary<string, string> ValuePairs { get; set; }
}
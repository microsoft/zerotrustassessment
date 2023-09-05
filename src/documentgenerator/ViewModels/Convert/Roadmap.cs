namespace ZeroTrustAssessment.DocumentGenerator.ViewModels.Convert;

public class Roadmap
{
    public Roadmap()
    {
        Identity = new List<RoadmapTask>();
        Device = new List<RoadmapTask>();
        DevSecOps = new List<RoadmapTask>();
    }
    
    public string TenantId { get; set; }
    public string TenantName { get; set; }
    public List<RoadmapTask> Identity { get; set; }
    public List<RoadmapTask> Device { get; set; }
    public List<RoadmapTask> DevSecOps { get; set; }
}
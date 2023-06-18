using System.Text.Json.Serialization;

namespace ZeroTrustAssessment.DocumentGenerator.Graph;

    public partial class GraphManagedAppStatusRaw
    {
        [JsonPropertyName("@odata.context")]
        public Uri OdataContext { get; set; }

        [JsonPropertyName("@odata.type")]
        public string OdataType { get; set; }

        [JsonPropertyName("displayName")]
        public string DisplayName { get; set; }

        [JsonPropertyName("id")]
        public string Id { get; set; }

        [JsonPropertyName("version")]
        public string Version { get; set; }

        [JsonPropertyName("content")]
        public Content Content { get; set; }
    }

    public partial class Content
    {
        [JsonPropertyName("@odata.type")]
        public string OdataType { get; set; }

        [JsonPropertyName("appList")]
        public AppList[] AppList { get; set; }
    }

    public partial class AppList
    {
        [JsonPropertyName("displayName")]
        public string DisplayName { get; set; }

        [JsonPropertyName("isFirstParty")]
        public bool IsFirstParty { get; set; }

        [JsonPropertyName("appIdentifier")]
        public AppIdentifier AppIdentifier { get; set; }
    }

    public partial class AppIdentifier
    {
        [JsonPropertyName("@odata.type")]
        public string OdataType { get; set; }

        [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
        [JsonPropertyName("bundleId")]
        public string BundleId { get; set; }

        [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
        [JsonPropertyName("packageId")]
        public string PackageId { get; set; }
    }

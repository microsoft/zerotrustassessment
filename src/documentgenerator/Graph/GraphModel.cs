using System.Text.Json.Serialization;

namespace ZeroTrustAssessment.DocumentGenerator.Graph;

public enum DirectorySettingTemplateEnum
{
    Application, //4bc7f740-180e-4586-adb6-38b2e9024e6b
    ConsentPolicySettings, //dffd5d46-495d-40a9-8e21-954ff55e198a
    CustomPolicySettings, //898f1161-d651-43d1-805c-3b0b388a9fc2
    GroupUnified, //62375ab9-6b52-47ed-826b-58e47e0e304b
    GroupUnifiedGuest, //08d542b9-071f-4e16-94b0-74abb372e3d9
    PasswordRuleSettings, //5cf42378-d67d-4f36-ba46-e8b86229381d
    ProhibitedNamesSettings, //80661d51-be2f-4d46-9713-98a2fcaec5bc
    ProhibitedNamesRestrictedSettings, //aad3907d-1d1a-448b-b3ef-7bf7f63db63b
}

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

namespace ZeroTrustAssessment.DocumentGenerator.ViewModels;
public class AppProtectionPolicyView
{
    // Common attributes
    public string? Id { get; set; }
    public string? Platform { get; set; }
    public string? PolicyType { get; set; }
    public string? DisplayName { get; set; }
    public string? PublicApps { get; set; }
    public string? CustomApps { get; set; }
    public string? PreventBackups { get; set; }
    public string? SendOrgDataToOtherApps { get; set; }
    public string? AppsToExempt { get; set; }
    public string? SaveCopiesOfOrgData { get; set; }
    public string? AllowUserToSaveCopiesToSelectedServices { get; set; }
    public string? TransferTelecommunicationDataTo { get; set; }
    public string? ReceiveDataFromOtherApps { get; set; }
    public string? OpenDataIntoOrgDocuments { get; set; }
    public string? AllowUsersToOpenDataFromSelectedServices { get; set; }
    public string? RestrictCutCopyAndPasteBetweenOtherApps { get; set; }
    public string? CutAndCopyCharacterLimitForAnyApp { get; set; }
    public string? EncryptOrgData { get; set; }
    public string? SyncPolicyManagedAppDataWithNativeAppsOrAddIns { get; set; }
    public string? PrintingOrgData { get; set; }
    public string? RestrictWebContentTransferWithOtherApps { get; set; }
    public string? OrgDataNotifications { get; set; }
    public string? MaxPinAttemptsAction { get; set; }
    public string? OfflineGracePeriodBlockAccessMin { get; set; }
    public string? OfflineGracePeriodWipeDataDays { get; set; }
    public string? DisabedAccount { get; set; }
    public string? MinAppVersionAction { get; set; }
    public string? RootedJailbrokenDevices { get; set; }
    public string? PrimaryMTDService { get; set; }
    public string? MaxAllowedDeviceThreatLevel { get; set; }
    public string? MinOSVersion { get; set; }
    public string? MaxOSVersion { get; set; }
    public string? RoleScopeTagIds { get; set; }
    public string? Scopes { get; set; }
    public string? IncludedGroups { get; set; }
    public string? ExcludedGroups { get; set; }
}
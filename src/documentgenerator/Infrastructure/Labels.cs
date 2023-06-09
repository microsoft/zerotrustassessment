namespace ZeroTrustAssessment.DocumentGenerator.Infrastructure;

public static class Labels
{
    public static readonly string PlatformAndroidForWork = "Android Enterprise (work profile)";
    public static readonly string PlatformAndroid = "Android device administrator";
    public static readonly string PlatformIos = "iOS/iPadOS";
    public static readonly string PlatformMacOs = "macOS";
    public static readonly string PlatformWindows = "Windows";

    public static readonly string NotApplicableString = "☉";
    public static readonly string RequireString = "Yes";
    public static readonly string ConfiguredString = "Configured";
    public static readonly string NotConfiguredString = "Not configured";
    public static readonly string BlockedString = "Blocked";

    public static string GetLabelYesNoBlank(bool? value)
    {
        if (value == null)
        {
            return string.Empty;
        }
        else if (value == true)
        {
            return "Yes";
        }
        else
        {
            return "No";
        }
    }

        public static string GetLabelAllowBlockBlank(bool? isBlocked)
    {
        if (isBlocked == null)
        {
            return string.Empty;
        }
        else if (isBlocked == true)
        {
            return "Block";
        }
        else
        {
            return "Allow";
        }
    }
}


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

    public static string ConvertStatusLabelToString(string label)
    {
        return label switch
        {
            "☉ Not started" => "Not started",
            "✜ Planned" => "Planned",
            "▷ In progress" => "In progress",
            "✓ Completed" => "Completed",
            "⦿ Blocked" => "Blocked",
            "※ Third Party" => "Third Party",
            "✕ Will not pursue" => "Will not pursue",
            "⚐ MS Roadmap" => "MS Roadmap",
            _ => label,
        };
    }

        public static string ConvertStatusStringToLabel(string value)
    {
        return value switch
        {
            "Not started" => "☉ Not started",
            "Planned" => "✜ Planned",
            "In progress" => "▷ In progress",
            "Completed" => "✓ Completed",
            "Blocked" => "⦿ Blocked",
            "Third Party" => "※ Third Party",
            "Will not pursue" => "✕ Will not pursue",
            "MS Roadmap" => "⚐ MS Roadmap",
            _ => value,
        };
    }
}


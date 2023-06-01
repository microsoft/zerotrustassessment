using System.Collections.Specialized;

namespace ZeroTrustAssessment.DocumentGenerator.Infrastructure;

public static class Helper
{

    public static string? GetObjectName(StringDictionary? cache, string id)
    {
        return GetObjectName(cache, id, null);
    }

    public static string? GetObjectName(StringDictionary? cache, string id, string? prefix)
    {
        string name;

        if (cache != null && cache.ContainsKey(id) && !string.IsNullOrEmpty(cache[id]))
        {
            name = cache[id];
        }
        else
        {
            if (Guid.TryParse(id, out _))
            {
                var shortId = GetShortId(id);
                name = prefix == null ? shortId : $"{prefix} ({shortId})";
            }
            else
            {
                name = id;
            }
        }

        return name;
    }

    public static void AppendObjectName(StringBuilder sb, StringDictionary? cache, string id)
    {
        sb.AppendLine($" - {GetObjectName(cache, id)}");
    }

    public static void AppendObjectNames(StringBuilder sb, StringDictionary? cache, IEnumerable<string> ids)
    {
        foreach (var id in ids)
        {
            AppendObjectName(sb, cache, id);
        }
    }

    public static string GetShortId(string id)
    {
        if (string.IsNullOrEmpty(id) || id.Length < 10) return id; //No need to shorten if it is already short

        var shortId = $"{id.Substring(0, 4)}...{id.Substring(id.Length - 4, 4)}";
        return shortId;
    }
}

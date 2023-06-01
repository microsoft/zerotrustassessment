using System.Collections.Specialized;
using System.IO;
using System.Text.Json;
using System.Text.Json.Nodes;
using Azure.Core;
using Microsoft.Kiota.Abstractions.Authentication;
using Microsoft.Kiota.Serialization.Json;

namespace ZeroTrustAssessment.DocumentGenerator.Graph;

public class GraphData
{
    public StringDictionary? ObjectCache { get; set; }
    public ICollection<Organization>? Organization { get; set; }
    public User? Me { get; set; }
    public ConfigOptions? ConfigOptions { get; private set; }
    private GraphHelper _graphHelper;

    public GraphData()
    {
        ConfigOptions = null;
    }

    public GraphData(ConfigOptions configOptions, string accessToken) //Web API call
    {
        ConfigOptions = configOptions;
        var graphClient = GetGraphClientUsingAccessToken(accessToken);
        _graphHelper = new GraphHelper(graphClient);
    }

    public GraphData(ConfigOptions configOptions, GraphHelper graphHelper) //Desktop/CLI app
    {
        ConfigOptions = configOptions;
        _graphHelper = graphHelper;
    }

    public async Task CollectData()
    {
        //TODO: Batch and call in parallel to improve perf
        Me = await _graphHelper.GetMe();
        Organization = await _graphHelper.GetOrganization();
        //Policies = await _graphHelper.GetPolicies();
    }

    private GraphServiceClient GetGraphClientUsingAccessToken(string accessToken)
    {
        var tokenProvider = new TokenProvider();
        tokenProvider.AccessToken = accessToken;
        var accessTokenProvider = new BaseBearerTokenAuthenticationProvider(tokenProvider);

        var graphClient = new GraphServiceClient(accessTokenProvider, "https://graph.microsoft.com/beta");
        return graphClient;
    }
}


public class TokenProvider : IAccessTokenProvider
{
    public string? AccessToken { get; set; }

    public Task<string> GetAuthorizationTokenAsync(Uri uri, Dictionary<string, object>? additionalAuthenticationContext = default,
        CancellationToken cancellationToken = default)
    {
        return Task.FromResult(AccessToken ?? string.Empty);
    }

#pragma warning disable CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Supressing since this is part of interface.
    public AllowedHostsValidator AllowedHostsValidator { get; }
#pragma warning restore CS8618 // Non-nullable field must contain a non-null value when exiting constructor. 
}
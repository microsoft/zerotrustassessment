<#
.SYNOPSIS
    Returns the canonical list of Microsoft Entra role definitions in scope for
    AI control-plane assessments.

.DESCRIPTION
    Centralizes the AI administrative role catalog used by ZTA AI-pillar tests
    (workshop guidance AI_149 - "Configure Privileged Roles to manage AI"). Each
    role is tagged with a Tier so callers can apply tier-specific logic - for
    example, Reader-tier roles (Global Reader, Security Reader) are downgraded
    from Fail to Investigate at tenant scope per the 61006 spec.

    Keeping this list in one place ensures every AI test that operates on the
    AI control-plane role surface (61006 today; future AI_149-family checks
    covering PIM hygiene, CA on AI admins, access reviews, etc.) evaluates the
    exact same set of roles.

    Role template IDs are sourced from Microsoft Entra built-in roles and are
    stable GUIDs.

.PARAMETER Tier
    Optional filter. When specified, returns only roles in the given tier
    ('Admin' or 'Reader'). Omit to return all roles.

.OUTPUTS
    System.Collections.Hashtable[] - one hashtable per role with keys:
    - Name : Role display name
    - Id   : Role template ID (GUID)
    - Tier : 'Admin' or 'Reader'

.EXAMPLE
    $roles = Get-ZtAiAdminRoleDefinitions

    Returns all AI control-plane roles.

.EXAMPLE
    $adminRoles = Get-ZtAiAdminRoleDefinitions -Tier 'Admin'

    Returns only the admin-tier AI roles (excludes Global Reader and Security
    Reader).

.NOTES
    Source: ztspecs/specs/ai/61006.md (AI_149).
    Used by: Test-Assessment-61006.
#>
function Get-ZtAiAdminRoleDefinitions {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable[]])]
    param(
        [ValidateSet('Admin', 'Reader')]
        [string] $Tier
    )

    $roles = @(
        @{ Name = 'AI Administrator';                   Id = 'd2562ede-74db-457e-a7b6-544e236ebb61'; Tier = 'Admin'  }
        @{ Name = 'Agent ID Administrator';             Id = 'db506228-d27e-4b7d-95e5-295956d6615f'; Tier = 'Admin'  }
        @{ Name = 'Agent ID Developer';                 Id = 'adb2368d-a9be-41b5-8667-d96778e081b0'; Tier = 'Admin'  }
        @{ Name = 'Agent Registry Administrator';       Id = '6b942400-691f-4bf0-9d12-d8a254a2baf5'; Tier = 'Admin'  }
        @{ Name = 'Application Administrator';          Id = '9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3'; Tier = 'Admin'  }
        @{ Name = 'Compliance Administrator';           Id = '17315797-102d-40b4-93e0-432062caca18'; Tier = 'Admin'  }
        @{ Name = 'Compliance Data Administrator';      Id = 'e6d1a23a-da11-4be4-9570-befc86d067a7'; Tier = 'Admin'  }
        @{ Name = 'Conditional Access Administrator';   Id = 'b1be1c3e-b65d-4f19-8427-f6fa0d97feb9'; Tier = 'Admin'  }
        @{ Name = 'Global Reader';                      Id = 'f2ef992c-3afb-46b9-b7cf-a126ee74c451'; Tier = 'Reader' }
        @{ Name = 'Global Secure Access Administrator'; Id = 'ac434307-12b9-4fa1-a708-88bf58caabc1'; Tier = 'Admin'  }
        @{ Name = 'Identity Governance Administrator';  Id = '45d8d3c5-c802-45c6-b32a-1d70b5e1e86e'; Tier = 'Admin'  }
        @{ Name = 'Intune Administrator';               Id = '3a2c62db-5318-420d-8d74-23affee5d9d5'; Tier = 'Admin'  }
        @{ Name = 'Power Platform Administrator';       Id = '11648597-926c-4cf3-9c36-bcebb0ba8dcc'; Tier = 'Admin'  }
        @{ Name = 'Security Administrator';             Id = '194ae4cb-b126-40b2-bd5b-6091b380977d'; Tier = 'Admin'  }
        @{ Name = 'Security Operator';                  Id = '5f2222b1-57c3-48ba-8ad5-d4759f1fde6f'; Tier = 'Admin'  }
        @{ Name = 'Security Reader';                    Id = '5d6b6bb7-de71-4623-b4af-96380a352509'; Tier = 'Reader' }
        @{ Name = 'SharePoint Administrator';           Id = 'f28a1f50-f6e7-4571-818b-6a12f2af6b6c'; Tier = 'Admin'  }
    )

    if ($Tier) {
        return @($roles | Where-Object { $_.Tier -eq $Tier })
    }

    return $roles
}

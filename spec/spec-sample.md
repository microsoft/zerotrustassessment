---
author.spec: ramical
author.doc: jflores
author.dev: merill
---
# Registering user should not be added as local administrator on the device during Microsoft Entra join

## Spec Status

Draft

## Documentation Status

Draft

## Dev Status

Draft

## Minimum License

AAD_P1

## Pillar

Device

## SFI Pillar

Protect devices

## Category

Device security

## Risk Level

High

## User Impact

Low

## Implementation Cost

Low

## Customer Facing Explanation

When a user performs a Microsoft Entra join, by default that user is automatically added to the local administrators group on the device. This default behavior creates a significant security risk because the joining user gains elevated privileges that can be exploited. If a threat actor compromises a user account that has performed Entra join on multiple devices, they immediately gain local administrator rights on all those devices. This enables credential dumping from local Security Account Manager (SAM) or cached credentials, installation of persistent backdoors or malware, disabling of local security controls such as Windows Defender, lateral movement to other systems using harvested credentials, and escalation to domain-level compromise. The principle of least privilege dictates that standard users should not have administrative access to their workstations. Organizations should disable this setting and instead use dedicated local admin accounts managed through Microsoft Entra Local Administrator Password Solution (LAPS) or assign local admin rights only to specific IT personnel through the Microsoft Entra Joined Device Local Administrator role.

## Check Query

* Query 1: Q1: Query the device registration policy to check local admin settings
https://graph.microsoft.com/beta/policies/deviceRegistrationPolicy

Documentation: [Get deviceRegistrationPolicy](https://learn.microsoft.com/en-us/graph/api/deviceregistrationpolicy-get?view=graph-rest-beta)

The API returns the `azureADJoin.localAdmins.registeringUsers` property which indicates who becomes a local administrator on Microsoft Entra joined devices they register. The `@odata.type` of `registeringUsers` determines the scope:
- `#microsoft.graph.noDeviceRegistrationMembership` - No registering users are added as local admins (Pass)
- `#microsoft.graph.allDeviceRegistrationMembership` - All registering users are added as local admins (Fail)
- `#microsoft.graph.enumeratedDeviceRegistrationMembership` - Specific users/groups are added as local admins (Fail if users or groups arrays are not empty)

## User facing message

Pass: Registering users are not automatically added as local administrators on Microsoft Entra joined devices.
Fail: Registering users are automatically added as local administrators on Microsoft Entra joined devices.

## Test evaluation logic

* Query Q1 to get the device registration policy
* Check the value of `azureADJoin.localAdmins.registeringUsers.@odata.type`:
  * If the value is `#microsoft.graph.noDeviceRegistrationMembership`, the test passes
  * If the value is `#microsoft.graph.allDeviceRegistrationMembership`, the test fails
  * If the value is `#microsoft.graph.enumeratedDeviceRegistrationMembership`:
    * Check if `azureADJoin.localAdmins.registeringUsers.users` array is empty AND `azureADJoin.localAdmins.registeringUsers.groups` array is empty
    * If both are empty, the test passes
    * If either array has values, the test fails

## Test output data

The test will output the current device registration policy settings for local administrators.

The output will be structured as a table with the following columns:
* Setting Name
* Current Value
* Status (Pass/Fail)

Output data:
* Registering Users Type (from `azureADJoin.localAdmins.registeringUsers.@odata.type`)
* Users Added as Local Admin (from `azureADJoin.localAdmins.registeringUsers.users` - if applicable)
* Groups Added as Local Admin (from `azureADJoin.localAdmins.registeringUsers.groups` - if applicable)

Link to portal: [Device Settings](https://entra.microsoft.com/#view/Microsoft_AAD_Devices/DevicesMenuBlade/~/DeviceSettings/menuId/Devices)

## Remediation resources

* [How to manage the local administrators group on Microsoft Entra joined devices](https://learn.microsoft.com/en-us/entra/identity/devices/assign-local-admin)
* [Manage device identities using the Microsoft Entra admin center](https://learn.microsoft.com/en-us/entra/identity/devices/manage-device-identities#configure-device-settings)
* [Windows Autopilot - Prevent users from becoming local admins](https://learn.microsoft.com/en-us/autopilot/enrollment-autopilot#create-an-autopilot-deployment-profile)
* [Windows Local Administrator Password Solution (LAPS) in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/devices/howto-manage-local-admin-passwords)

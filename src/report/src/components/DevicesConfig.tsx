import { reportData } from "@/config/report-data";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";

export default function DevicesConfig() {
    const enrollment = reportData.TenantInfo?.ConfigWindowsEnrollment;
    const enrollmentRestrictions = reportData.TenantInfo?.ConfigDeviceEnrollmentRestriction;
    const compliancePolicies = reportData.TenantInfo?.ConfigDeviceCompliancePolicies;
    const appProtectionPolicies = reportData.TenantInfo?.ConfigDeviceAppProtectionPolicies;
    return (
        <div className="p-4">
            <h2 className="text-lg font-semibold mb-4">Windows automatic enrollment</h2>
            <p className="text-sm text-gray-600 mb-4">
                Configure Windows devices to enroll when they join or register with Azure Active Directory. We recommend setting this to all instead of selected groups and using enrollment restrictions to configure the intake of users.
            </p>
            {enrollment && enrollment.length > 0 ? (
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>Type</TableHead>
                            <TableHead>Policy Name</TableHead>
                            <TableHead>Applies To</TableHead>
                            <TableHead>Groups</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {enrollment.map((row, idx) => (
                            <TableRow key={idx}>
                                <TableCell>{row.Type}</TableCell>
                                <TableCell>{row.PolicyName}</TableCell>
                                <TableCell>{row.AppliesTo}</TableCell>
                                <TableCell>{row.Groups}</TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            ) : (
                <p>No Windows enrollment configuration found.</p>
            )}

            <h2 className="text-lg font-semibold mb-4 mt-8">Enrollment device platform restrictions</h2>
            <p className="text-sm text-gray-600 mb-4">
                Device enrollment restrictions let you restrict devices from enrolling in Intune based on certain device attributes. Device platform restrictions restrict devices based on device platform, version, manufacturer, or ownership type.
            </p>
            {enrollmentRestrictions && enrollmentRestrictions.length > 0 ? (
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>Platform</TableHead>
                            <TableHead>Priority</TableHead>
                            <TableHead>Name</TableHead>
                            <TableHead>MDM</TableHead>
                            <TableHead>Min Ver</TableHead>
                            <TableHead>Max Ver</TableHead>
                            <TableHead>Personally owned</TableHead>
                            <TableHead>Blocked manuf.</TableHead>
                            <TableHead>Scope</TableHead>
                            <TableHead>Assigned to</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {enrollmentRestrictions.map((row, idx) => (
                            <TableRow key={idx}>
                                <TableCell>{row.Platform}</TableCell>
                                <TableCell>{row.Priority}</TableCell>
                                <TableCell>{row.Name}</TableCell>
                                <TableCell>{row.MDM}</TableCell>
                                <TableCell>{row.MinVer}</TableCell>
                                <TableCell>{row.MaxVer}</TableCell>
                                <TableCell>{row.PersonallyOwned}</TableCell>
                                <TableCell>{row.BlockedManufacturers}</TableCell>
                                <TableCell>{row.Scope}</TableCell>
                                <TableCell>{row.AssignedTo}</TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            ) : (
                <p>No device enrollment restrictions found.</p>
            )}

            <h2 className="text-lg font-semibold mb-4 mt-8">Compliance policies</h2>
            <p className="text-sm text-gray-600 mb-4">
                Device compliance policies define the rules and settings that devices must meet to be considered compliant. These policies help ensure that devices accessing organizational resources meet minimum security requirements.
            </p>
            {compliancePolicies && compliancePolicies.length > 0 ? (
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>Platform</TableHead>
                            <TableHead>Policy Name</TableHead>
                            <TableHead>Defender ATP</TableHead>
                            <TableHead>Min OS Version</TableHead>
                            <TableHead>Max OS Version</TableHead>
                            <TableHead>Require Password</TableHead>
                            <TableHead>Min Password Length</TableHead>
                            <TableHead>Password Type</TableHead>
                            <TableHead>Password Expiry Days</TableHead>
                            <TableHead>Previous Passwords Blocked</TableHead>
                            <TableHead>Max Inactivity Min</TableHead>
                            <TableHead>Require Encryption</TableHead>
                            <TableHead>Rooted/Jailbroken</TableHead>
                            <TableHead>Max Threat Level</TableHead>
                            <TableHead>Require Firewall</TableHead>
                            <TableHead>Push Notification Days</TableHead>
                            <TableHead>Send Email Days</TableHead>
                            <TableHead>Remote Lock Days</TableHead>
                            <TableHead>Block Days</TableHead>
                            <TableHead>Retire Days</TableHead>
                            <TableHead>Scope</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {compliancePolicies.map((row, idx) => (
                            <TableRow key={idx}>
                                <TableCell>{row.Platform}</TableCell>
                                <TableCell>{row.PolicyName}</TableCell>
                                <TableCell>{row.DefenderForEndPoint}</TableCell>
                                <TableCell>{row.MinOsVersion}</TableCell>
                                <TableCell>{row.MaxOsVersion}</TableCell>
                                <TableCell>{row.RequirePswd}</TableCell>
                                <TableCell>{row.MinPswdLength}</TableCell>
                                <TableCell>{row.PasswordType}</TableCell>
                                <TableCell>{row.PswdExpiryDays}</TableCell>
                                <TableCell>{row.CountOfPreviousPswdToBlock}</TableCell>
                                <TableCell>{row.MaxInactivityMin}</TableCell>
                                <TableCell>{row.RequireEncryption}</TableCell>
                                <TableCell>{row.RootedJailbrokenDevices}</TableCell>
                                <TableCell>{row.MaxDeviceThreatLevel}</TableCell>
                                <TableCell>{row.RequireFirewall}</TableCell>
                                <TableCell>{row.ActionForNoncomplianceDaysPushNotification}</TableCell>
                                <TableCell>{row.ActionForNoncomplianceDaysSendEmail}</TableCell>
                                <TableCell>{row.ActionForNoncomplianceDaysRemoteLock}</TableCell>
                                <TableCell>{row.ActionForNoncomplianceDaysBlock}</TableCell>
                                <TableCell>{row.ActionForNoncomplianceDaysRetire}</TableCell>
                                <TableCell>{row.Scope}</TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            ) : (
                <p>No device compliance policies found.</p>
            )}

            <h2 className="text-lg font-semibold mb-4 mt-8">App protection policies</h2>
            <p className="text-sm text-gray-600 mb-4">
                App protection policies (APP) are rules that ensure an organization's data remains safe or contained in a managed app. A policy can be a rule that is enforced when the user attempts to access or move "corporate" data, or a set of actions that are prohibited or monitored when the user is inside the app. A managed app is an app that has app protection policies applied to it, and can be managed by Intune.
            </p>
            {appProtectionPolicies && appProtectionPolicies.length > 0 ? (
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>Platform</TableHead>
                            <TableHead>Name</TableHead>
                            <TableHead>Public Apps</TableHead>
                            <TableHead>Custom Apps</TableHead>
                            <TableHead>Backup to Cloud</TableHead>
                            <TableHead>Send Data to Other Apps</TableHead>
                            <TableHead>Apps to Exempt</TableHead>
                            <TableHead>Save Copies</TableHead>
                            <TableHead>Allow Save to Selected Services</TableHead>
                            <TableHead>Transfer Telecom Data To</TableHead>
                            <TableHead>Receive Data From Other Apps</TableHead>
                            <TableHead>Open Data in Org Documents</TableHead>
                            <TableHead>Allow Open from Selected Services</TableHead>
                            <TableHead>Restrict Cut/Copy Between Apps</TableHead>
                            <TableHead>Cut/Copy Character Limit</TableHead>
                            <TableHead>Encrypt Org Data</TableHead>
                            <TableHead>Sync with Native Apps</TableHead>
                            <TableHead>Printing</TableHead>
                            <TableHead>Restrict Web Content Transfer</TableHead>
                            <TableHead>Org Data Notifications</TableHead>
                            <TableHead>Max PIN Attempts</TableHead>
                            <TableHead>Offline Grace Period Block</TableHead>
                            <TableHead>Offline Grace Period Wipe</TableHead>
                            <TableHead>Disabled Account</TableHead>
                            <TableHead>Min App Version</TableHead>
                            <TableHead>Rooted/Jailbroken Devices</TableHead>
                            <TableHead>Primary MTD Service</TableHead>
                            <TableHead>Max Device Threat Level</TableHead>
                            <TableHead>Min OS Version</TableHead>
                            <TableHead>Max OS Version</TableHead>
                            <TableHead>Scope</TableHead>
                            <TableHead>Included Groups</TableHead>
                            <TableHead>Excluded Groups</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {appProtectionPolicies.map((row, idx) => (
                            <TableRow key={idx}>
                                <TableCell>{row.Platform}</TableCell>
                                <TableCell>{row.Name}</TableCell>
                                <TableCell>{row.AppsPublic}</TableCell>
                                <TableCell>{row.AppsCustom}</TableCell>
                                <TableCell>{row.BackupOrgDataToICloudOrGoogle}</TableCell>
                                <TableCell>{row.SendOrgDataToOtherApps}</TableCell>
                                <TableCell>{row.AppsToExempt}</TableCell>
                                <TableCell>{row.SaveCopiesOfOrgData}</TableCell>
                                <TableCell>{row.AllowUserToSaveCopiesToSelectedServices}</TableCell>
                                <TableCell>{row.DataProtectionTransferTelecommunicationDataTo}</TableCell>
                                <TableCell>{row.DataProtectionReceiveDataFromOtherApps}</TableCell>
                                <TableCell>{row.DataProtectionOpenDataIntoOrgDocuments}</TableCell>
                                <TableCell>{row.DataProtectionAllowUsersToOpenDataFromSelectedServices}</TableCell>
                                <TableCell>{row.DataProtectionRestrictCutCopyBetweenOtherApps}</TableCell>
                                <TableCell>{row.DataProtectionCutCopyCharacterLimitForAnyApp}</TableCell>
                                <TableCell>{row.DataProtectionEncryptOrgData}</TableCell>
                                <TableCell>{row.DataProtectionSyncPolicyManagedAppDataWithNativeApps}</TableCell>
                                <TableCell>{row.DataProtectionPrintingOrgData}</TableCell>
                                <TableCell>{row.DataProtectionRestrictWebContentTransferWithOtherApps}</TableCell>
                                <TableCell>{row.DataProtectionOrgDataNotifications}</TableCell>
                                <TableCell>{row.ConditionalLaunchAppMaxPinAttempts}</TableCell>
                                <TableCell>{row.ConditionalLaunchAppOfflineGracePeriodBlockAccess}</TableCell>
                                <TableCell>{row.ConditionalLaunchAppOfflineGracePeriodWipeData}</TableCell>
                                <TableCell>{row.ConditionalLaunchAppDisabedAccount}</TableCell>
                                <TableCell>{row.ConditionalLaunchAppMinAppVersion}</TableCell>
                                <TableCell>{row.ConditionalLaunchDeviceRootedJailbrokenDevices}</TableCell>
                                <TableCell>{row.ConditionalLaunchDevicePrimaryMtdService}</TableCell>
                                <TableCell>{row.ConditionalLaunchDeviceMaxAllowedDeviceThreatLevel}</TableCell>
                                <TableCell>{row.ConditionalLaunchDeviceMinOsVersion}</TableCell>
                                <TableCell>{row.ConditionalLaunchDeviceMaxOsVersion}</TableCell>
                                <TableCell>{row.Scope}</TableCell>
                                <TableCell>{row.IncludedGroups}</TableCell>
                                <TableCell>{row.ExcludedGroups}</TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            ) : (
                <p>No app protection policies found.</p>
            )}
        </div>
    );
}

import { reportData } from "@/config/report-data";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";

export default function DevicesConfig() {
    const enrollment = reportData.TenantInfo?.ConfigWindowsEnrollment;
    const enrollmentRestrictions = reportData.TenantInfo?.ConfigDeviceEnrollmentRestriction;
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
        </div>
    );
}

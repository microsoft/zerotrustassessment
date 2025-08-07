import { reportData } from "@/config/report-data";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";

export default function DevicesConfig() {
    const enrollment = reportData.TenantInfo?.ConfigWindowsEnrollment;
    return (
        <div className="p-4">
            <h2 className="text-lg font-semibold mb-4">Windows Enrollment Configuration</h2>
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
        </div>
    );
}

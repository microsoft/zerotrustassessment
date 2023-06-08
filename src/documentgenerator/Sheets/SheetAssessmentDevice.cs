using Syncfusion.XlsIO;
using ZeroTrustAssessment.DocumentGenerator.Graph;

namespace ZeroTrustAssessment.DocumentGenerator.Sheets;

public class SheetAssessmentDevice : SheetBase
{
    public SheetAssessmentDevice(IWorksheet sheet, GraphData graphData) : base(sheet, graphData)
    {
    }

    public void Generate()
    {
        MdmWindowsEnrollment();
        DeviceEnrollmentConfiguration();
    }

    private void MdmWindowsEnrollment()
    {
        var isMdmEnrolled = _graphData.MobilityManagementPolicies?.Any(x => x.IsValid == true && x?.AppliesTo != PolicyScope.None);
        var result = isMdmEnrolled.HasValue && isMdmEnrolled.Value ? AssessmentValue.Completed : AssessmentValue.NotStarted;
        SetValue("CH00001_WindowsEnrollment", result);
    }

    private void DeviceEnrollmentConfiguration()
    {
        var enrollmentConfigs = _graphData.DeviceEnrollmentConfigurations?.Where(x => x.DeviceEnrollmentConfigurationType == DeviceEnrollmentConfigurationType.SinglePlatformRestriction);
        var android = AssessmentValue.NotStarted;
        var windows = AssessmentValue.NotStarted;
        var ios = AssessmentValue.NotStarted;
        var macos = AssessmentValue.NotStarted;


        if (enrollmentConfigs != null)
        {
            foreach (var config in enrollmentConfigs)
            {
                if (config is DeviceEnrollmentPlatformRestrictionConfiguration restriction)
                {
                    switch (restriction.PlatformType)
                    {
                        case EnrollmentRestrictionPlatformType.Android:
                            android = AssessmentValue.Completed;
                            break;
                        case EnrollmentRestrictionPlatformType.Windows:
                            windows = AssessmentValue.Completed;
                            break;
                        case EnrollmentRestrictionPlatformType.Ios:
                            ios = AssessmentValue.Completed;
                            break;
                        case EnrollmentRestrictionPlatformType.Mac:
                            macos = AssessmentValue.Completed;
                            break;
                    }
                }
            }

            // var isDeviceEnrollmentConfigured = enrollmentConfigs.Where(x => x.) _graphData.MobilityManagementPolicies?.Any(x => x.IsValid == true && x?.AppliesTo != PolicyScope.None);
            // var result = isDeviceEnrollmentConfigured.HasValue && isDeviceEnrollmentConfigured.Value ? AssessmentValue.Completed : AssessmentValue.NotStarted;
        }
        //TODO: Check the group count and if empty set to In Progress.
        SetValue("CH00002_DeviceEnrollment_Android", android);
        SetValue("CH00003_DeviceEnrollment_Windows", windows);
        SetValue("CH00004_DeviceEnrollment_iOS", ios);
        SetValue("CH00005_DeviceEnrollment_macOS", macos);
    }
}
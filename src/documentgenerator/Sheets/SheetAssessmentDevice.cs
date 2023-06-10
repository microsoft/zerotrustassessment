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

        //Check if any of the platforms are disabled in the default policy
        var defaultPlatformRestrictions = _graphData.DeviceEnrollmentConfigurations?
            .Where(x => x.DeviceEnrollmentConfigurationType == DeviceEnrollmentConfigurationType.PlatformRestrictions).FirstOrDefault();
        if (defaultPlatformRestrictions != null && defaultPlatformRestrictions is DeviceEnrollmentPlatformRestrictionsConfiguration defaultRestriction)
        {
            if(defaultRestriction?.AndroidRestriction?.PlatformBlocked == false || 
                defaultRestriction?.AndroidForWorkRestriction?.PlatformBlocked == false ) { android = AssessmentValue.Completed; }
            if(defaultRestriction?.IosRestriction?.PlatformBlocked == false) { ios = AssessmentValue.Completed; }
            if(defaultRestriction?.MacRestriction?.PlatformBlocked == false) { macos = AssessmentValue.Completed; }
            if(defaultRestriction?.WindowsRestriction?.PlatformBlocked == false) { windows =  AssessmentValue.Completed; }
        }

        if (enrollmentConfigs != null) //Check if a custom policy has been created and mark as completed if one is found.
        {
            foreach (var config in enrollmentConfigs)
            {
                if (config is DeviceEnrollmentPlatformRestrictionConfiguration restriction)
                {
                    switch (restriction.PlatformType)
                    {
                        case EnrollmentRestrictionPlatformType.Android:
                        case EnrollmentRestrictionPlatformType.AndroidForWork:
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
        }


        //TODO: Future enhancement: Check transitive group count and if less than 10 (or maybe 10% of users) then set to In Progress.
        SetValue("CH00002_DeviceEnrollment_Android", android);
        SetValue("CH00003_DeviceEnrollment_Windows", windows);
        SetValue("CH00004_DeviceEnrollment_iOS", ios);
        SetValue("CH00005_DeviceEnrollment_macOS", macos);
    }
}
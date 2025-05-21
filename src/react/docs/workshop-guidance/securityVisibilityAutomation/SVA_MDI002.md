## Install Defender for Identity sensors on all Domain Controllers

**Implementation Effort:** High

**User Impact:** Medium

## Overview


**Download the Defender for Identity sensor**
1. In the Microsoft 365 Defender portal, in the left mentu, select **Settings>Identities**
2. On the **General** tab, select **Sensors**
3. On the **Sensors** page, select **Add Sensor**
4. On the **Add a new sensor** panel, select **Download Installer**
5. Copy the access key and the installer to the domain controller, AD FS server, or AD CS server

**Install the Defender for Identity sensor on a domain controller**
1. Run and extract **Azure ATP sensor setup.exe** as an admin
2. Select **Language**, then select **Next**
3. Select **Deployment Type, then select **Next*
4. On the **Configure the Sensor** page, enter the installation path, paste the access key, and then select **Next**
5. Select **Install**

**Install the Defender for Identity sensor in an AD FS environment**

1. Run and extract **Azure ATP sensor setup.exe** as an admin
2. Select **Language**, then select **Next**
3. On the **Sensors** page, select the AD FS deployment type, then select **Next**
4. To set up the sensor, enter the installation path, then select **Next**
5. Select **Install**
6. **Select the sensor installed on the AD FS server**
    * On the **Sensors** page, in the **Resolve Domain Controllers** box, enter the **FQDN**
    * Select the plus (+) icon, then select **Save**


**Install the Defender for Identity sensor on an AD CS server**
1. Run and extract **Azure ATP sensor setup.exe** as an admin
2. Select **Language**, then select **Next**
3. On the **Sensors** page, select the AD CS deployment type, then select **Next**
4. To set up the sensor, enter the installation path, then select **Next**
6. Select **Install**


## Reference
* https://admin.microsoft.com/#/SetupGuidance
* https://learn.microsoft.com/en-us/defender-for-identity/deploy/install-sensor

Microsoft 365 traffic is protected only when Global Secure Access acquires the traffic and Conditional Access requires the compliant network signal. Acquisition supplies the Security Service Edge visibility and signal; enforcement makes that signal mandatory before access is granted.

**Remediation action**
- Enable the Microsoft traffic forwarding profile and deploy the Global Secure Access client to managed devices.
- Enable Global Secure Access signaling for Conditional Access and configure a compliant network named location.
- Enable a Conditional Access policy that blocks access from all locations except the compliant network.

<!--- Results --->
%TestResult%

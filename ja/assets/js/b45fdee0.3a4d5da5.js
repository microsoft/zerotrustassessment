"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[2966],{24149:(e,s,n)=>{n.r(s),n.d(s,{assets:()=>a,contentTitle:()=>c,default:()=>d,frontMatter:()=>r,metadata:()=>o,toc:()=>l});var i=n(74848),t=n(28453);const r={},c="018: Review security, compliance, resource access requirements (Certs/Wi-Fi/VPN)",o={id:"workshop-guidance/devices/RMD_018",title:"018: Review security, compliance, resource access requirements (Certs/Wi-Fi/VPN)",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_018.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_018",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_018",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_018.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"017: Review enrolled vs unenrolled for BYOD/Corporate",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_017"},next:{title:"019: Review App config vs App protection policies",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_019"}},a={},l=[{value:"Overview",id:"overview",level:2},{value:"Options for Certificates, Wi-Fi, and VPN for MDM for iOS in Intune",id:"options-for-certificates-wi-fi-and-vpn-for-mdm-for-ios-in-intune",level:3},{value:"Certificates",id:"certificates",level:4},{value:"Wi-Fi",id:"wi-fi",level:4},{value:"VPN",id:"vpn",level:4},{value:"Zero Trust Security Posture",id:"zero-trust-security-posture",level:4},{value:"Reference",id:"reference",level:2}];function u(e){const s={a:"a",h1:"h1",h2:"h2",h3:"h3",h4:"h4",header:"header",li:"li",ol:"ol",p:"p",strong:"strong",ul:"ul",...(0,t.R)(),...e.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(s.header,{children:(0,i.jsx)(s.h1,{id:"018-review-security-compliance-resource-access-requirements-certswi-fivpn",children:"018: Review security, compliance, resource access requirements (Certs/Wi-Fi/VPN)"})}),"\n",(0,i.jsx)(s.h2,{id:"overview",children:"Overview"}),"\n",(0,i.jsx)(s.h3,{id:"options-for-certificates-wi-fi-and-vpn-for-mdm-for-ios-in-intune",children:"Options for Certificates, Wi-Fi, and VPN for MDM for iOS in Intune"}),"\n",(0,i.jsx)(s.p,{children:"When managing iOS devices with Microsoft Intune, you have several options for configuring certificates, Wi-Fi, and VPN settings. These configurations are crucial for ensuring secure and seamless access to corporate resources. Here\u2019s a detailed look at the available options, their benefits, and how they contribute to a Zero Trust security posture."}),"\n",(0,i.jsx)(s.h4,{id:"certificates",children:"Certificates"}),"\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Options"}),":"]}),"\n",(0,i.jsxs)(s.ol,{children:["\n",(0,i.jsxs)(s.li,{children:["\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Simple Certificate Enrollment Protocol (SCEP)"}),":"]}),"\n",(0,i.jsxs)(s.ul,{children:["\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Purpose"}),": Automates the issuance and renewal of certificates."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Use Case"}),": Ideal for large-scale deployments where automated certificate management is needed\xb9(",(0,i.jsx)(s.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/certificates-configure",children:"https://learn.microsoft.com/en-us/mem/intune/protect/certificates-configure"}),")."]}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(s.li,{children:["\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Public Key Cryptography Standards (PKCS)"}),":"]}),"\n",(0,i.jsxs)(s.ul,{children:["\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Purpose"}),": Provides a more controlled certificate issuance process."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Use Case"}),": Suitable for environments requiring high security and manual certificate management\xb9(",(0,i.jsx)(s.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/certificates-configure",children:"https://learn.microsoft.com/en-us/mem/intune/protect/certificates-configure"}),")."]}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(s.li,{children:["\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Imported PKCS Certificates"}),":"]}),"\n",(0,i.jsxs)(s.ul,{children:["\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Purpose"}),": Allows importing pre-issued certificates."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Use Case"}),": Useful for integrating with existing certificate infrastructures\xb9(",(0,i.jsx)(s.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/certificates-configure",children:"https://learn.microsoft.com/en-us/mem/intune/protect/certificates-configure"}),")."]}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Benefits"}),":"]}),"\n",(0,i.jsxs)(s.ul,{children:["\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Enhanced Security"}),": Certificates provide strong authentication, reducing the risk of unauthorized access\xb2(",(0,i.jsx)(s.a,{href:"https://microsoft.github.io/zerotrustassessment/docs/workshop-guidance/devices/RMD_179",children:"https://microsoft.github.io/zerotrustassessment/docs/workshop-guidance/devices/RMD_179"}),")."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Seamless User Experience"}),": Users can access resources without repeatedly entering credentials\xb2(",(0,i.jsx)(s.a,{href:"https://microsoft.github.io/zerotrustassessment/docs/workshop-guidance/devices/RMD_179",children:"https://microsoft.github.io/zerotrustassessment/docs/workshop-guidance/devices/RMD_179"}),")."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Centralized Management"}),": Simplifies the deployment and management of certificates across all devices\xb2(",(0,i.jsx)(s.a,{href:"https://microsoft.github.io/zerotrustassessment/docs/workshop-guidance/devices/RMD_179",children:"https://microsoft.github.io/zerotrustassessment/docs/workshop-guidance/devices/RMD_179"}),")."]}),"\n"]}),"\n",(0,i.jsx)(s.h4,{id:"wi-fi",children:"Wi-Fi"}),"\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Options"}),":"]}),"\n",(0,i.jsxs)(s.ol,{children:["\n",(0,i.jsxs)(s.li,{children:["\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Basic Wi-Fi Configuration"}),":"]}),"\n",(0,i.jsxs)(s.ul,{children:["\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Purpose"}),": Connects devices to a Wi-Fi network using SSID and password."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Use Case"}),": Suitable for simple network setups(",(0,i.jsx)(s.a,{href:"https://www.youtube.com/watch?v=-edLIdPu-FE",children:"https://www.youtube.com/watch?v=-edLIdPu-FE"}),")."]}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(s.li,{children:["\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Enterprise Wi-Fi Configuration"}),":"]}),"\n",(0,i.jsxs)(s.ul,{children:["\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Purpose"}),": Uses certificates for authentication (e.g., WPA2-Enterprise)."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Use Case"}),": Ideal for secure corporate networks requiring strong authentication(",(0,i.jsx)(s.a,{href:"https://www.youtube.com/watch?v=-edLIdPu-FE",children:"https://www.youtube.com/watch?v=-edLIdPu-FE"}),")."]}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Benefits"}),":"]}),"\n",(0,i.jsxs)(s.ul,{children:["\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Automated Connectivity"}),": Ensures devices automatically connect to the corporate Wi-Fi network."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Improved Security"}),": Enterprise configurations provide stronger security through certificate-based authentication."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"User Productivity"}),": Reduces the need for manual Wi-Fi configuration by users."]}),"\n"]}),"\n",(0,i.jsx)(s.h4,{id:"vpn",children:"VPN"}),"\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Options"}),":"]}),"\n",(0,i.jsxs)(s.ol,{children:["\n",(0,i.jsxs)(s.li,{children:["\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Per-App VPN"}),":"]}),"\n",(0,i.jsxs)(s.ul,{children:["\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Purpose"}),": Directs traffic from specific apps through a VPN."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Use Case"}),": Useful for securing sensitive app data without routing all device traffic through the VPN(",(0,i.jsx)(s.a,{href:"https://www.youtube.com/watch?v=5eZNwYB6DZ4",children:"https://www.youtube.com/watch?v=5eZNwYB6DZ4"}),")."]}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(s.li,{children:["\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Device-Wide VPN"}),":"]}),"\n",(0,i.jsxs)(s.ul,{children:["\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Purpose"}),": Routes all device traffic through a VPN."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Use Case"}),": Suitable for scenarios where all network traffic needs to be secured(",(0,i.jsx)(s.a,{href:"https://www.youtube.com/watch?v=5eZNwYB6DZ4",children:"https://www.youtube.com/watch?v=5eZNwYB6DZ4"}),")."]}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Benefits"}),":"]}),"\n",(0,i.jsxs)(s.ul,{children:["\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Secure Access"}),": Ensures secure connections to corporate resources, even from remote locations."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Continuous Verification"}),": Regularly updated VPN settings help maintain secure access."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Flexibility"}),": Per-app VPN allows for granular control over which apps use the VPN."]}),"\n"]}),"\n",(0,i.jsx)(s.h4,{id:"zero-trust-security-posture",children:"Zero Trust Security Posture"}),"\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Zero Trust"})," is a security model that assumes no implicit trust and continuously verifies every access request. Here\u2019s how these configurations align with Zero Trust principles:"]}),"\n",(0,i.jsxs)(s.ol,{children:["\n",(0,i.jsxs)(s.li,{children:["\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Verify Explicitly"}),":"]}),"\n",(0,i.jsxs)(s.ul,{children:["\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Certificates"}),": Provide strong, certificate-based authentication, ensuring that only authorized users and devices can access resources."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Wi-Fi"}),": Enterprise Wi-Fi configurations use certificates to authenticate devices, ensuring secure network access."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"VPN"}),": VPN profiles enforce secure connections, ensuring that only authorized devices can access the network."]}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(s.li,{children:["\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Use Least Privilege Access"}),":"]}),"\n",(0,i.jsxs)(s.ul,{children:["\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Per-App VPN"}),": Limits VPN usage to specific apps, reducing the attack surface."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Conditional Access"}),": Intune policies can enforce conditional access, ensuring that only compliant devices can access sensitive resources."]}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(s.li,{children:["\n",(0,i.jsxs)(s.p,{children:[(0,i.jsx)(s.strong,{children:"Assume Breach"}),":"]}),"\n",(0,i.jsxs)(s.ul,{children:["\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Continuous Monitoring"}),": Integrates with mobile threat defense solutions to continuously monitor device health and compliance(",(0,i.jsx)(s.a,{href:"https://learn.microsoft.com/en-us/mem/intune/fundamentals/zero-trust-with-microsoft-intune",children:"https://learn.microsoft.com/en-us/mem/intune/fundamentals/zero-trust-with-microsoft-intune"}),")."]}),"\n",(0,i.jsxs)(s.li,{children:[(0,i.jsx)(s.strong,{children:"Automated Remediation"}),": Policies can automatically remediate non-compliant devices, maintaining a secure environment(",(0,i.jsx)(s.a,{href:"https://learn.microsoft.com/en-us/mem/intune/fundamentals/zero-trust-with-microsoft-intune",children:"https://learn.microsoft.com/en-us/mem/intune/fundamentals/zero-trust-with-microsoft-intune"}),")."]}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,i.jsx)(s.p,{children:"By leveraging these configurations, organizations can enhance their security posture, streamline device management, and ensure compliance, all while adhering to the principles of Zero Trust."}),"\n",(0,i.jsx)(s.h2,{id:"reference",children:"Reference"}),"\n",(0,i.jsxs)(s.p,{children:["(1) Types of certificate that are supported by Microsoft Intune. ",(0,i.jsx)(s.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/certificates-configure",children:"https://learn.microsoft.com/en-us/mem/intune/protect/certificates-configure"}),".\n(2) Configure WIFI Profile using Intune |A Step-by-Step Guide | Microsoft Intune. ",(0,i.jsx)(s.a,{href:"https://www.youtube.com/watch?v=-edLIdPu-FE",children:"https://www.youtube.com/watch?v=-edLIdPu-FE"}),".\n(3) S01E33 - Configuring VPN Profiles with Microsoft Intune - (I.T). ",(0,i.jsx)(s.a,{href:"https://www.youtube.com/watch?v=5eZNwYB6DZ4",children:"https://www.youtube.com/watch?v=5eZNwYB6DZ4"}),".\n(4) Zero Trust with Microsoft Intune | Microsoft Learn. ",(0,i.jsx)(s.a,{href:"https://learn.microsoft.com/en-us/mem/intune/fundamentals/zero-trust-with-microsoft-intune",children:"https://learn.microsoft.com/en-us/mem/intune/fundamentals/zero-trust-with-microsoft-intune"}),".\n(5) Deployment guide: Manage iOS/iPadOS devices in Microsoft Intune. ",(0,i.jsx)(s.a,{href:"https://learn.microsoft.com/en-us/mem/intune/fundamentals/deployment-guide-platform-ios-ipados",children:"https://learn.microsoft.com/en-us/mem/intune/fundamentals/deployment-guide-platform-ios-ipados"}),".\n(6) iOS/iPadOS device settings in Microsoft Intune | Microsoft Learn. ",(0,i.jsx)(s.a,{href:"https://learn.microsoft.com/en-us/mem/intune/configuration/device-restrictions-ios",children:"https://learn.microsoft.com/en-us/mem/intune/configuration/device-restrictions-ios"}),".\n(7) Create and Deploy Wifi profile in Microsoft Intune. ",(0,i.jsx)(s.a,{href:"https://www.youtube.com/watch?v=-jq90KneBxI",children:"https://www.youtube.com/watch?v=-jq90KneBxI"}),".\n(8) Planning guide to move to Microsoft Intune | Microsoft Learn. ",(0,i.jsx)(s.a,{href:"https://learn.microsoft.com/en-us/mem/intune/fundamentals/intune-planning-guide",children:"https://learn.microsoft.com/en-us/mem/intune/fundamentals/intune-planning-guide"}),"."]})]})}function d(e={}){const{wrapper:s}={...(0,t.R)(),...e.components};return s?(0,i.jsx)(s,{...e,children:(0,i.jsx)(u,{...e})}):u(e)}},28453:(e,s,n)=>{n.d(s,{R:()=>c,x:()=>o});var i=n(96540);const t={},r=i.createContext(t);function c(e){const s=i.useContext(r);return i.useMemo((function(){return"function"==typeof e?e(s):{...s,...e}}),[s,e])}function o(e){let s;return s=e.disableParentContext?"function"==typeof e.components?e.components(t):e.components||t:c(e.components),i.createElement(r.Provider,{value:s},e.children)}}}]);
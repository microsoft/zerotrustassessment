"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[3713],{35889:(e,n,i)=>{i.r(n),i.d(n,{assets:()=>l,contentTitle:()=>r,default:()=>d,frontMatter:()=>o,metadata:()=>c,toc:()=>a});var s=i(74848),t=i(28453);const o={},r="133: MDM based policies for VPN",c={id:"workshop-guidance/devices/RMD_133",title:"133: MDM based policies for VPN",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_133.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_133",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_133",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_133.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"132: MDM based policies for Wi-Fi",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_132"},next:{title:"134: Browser",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_134"}},l={},a=[{value:"Overview",id:"overview",level:2},{value:"Benefits",id:"benefits",level:3},{value:"Drawbacks",id:"drawbacks",level:3},{value:"Impact on End Users",id:"impact-on-end-users",level:3},{value:"Tying to Zero Trust",id:"tying-to-zero-trust",level:3},{value:"Reference",id:"reference",level:2}];function u(e){const n={a:"a",h1:"h1",h2:"h2",h3:"h3",header:"header",li:"li",ol:"ol",p:"p",strong:"strong",ul:"ul",...(0,t.R)(),...e.components};return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)(n.header,{children:(0,s.jsx)(n.h1,{id:"133-mdm-based-policies-for-vpn",children:"133: MDM based policies for VPN"})}),"\n",(0,s.jsx)(n.h2,{id:"overview",children:"Overview"}),"\n",(0,s.jsx)(n.p,{children:"Deploying VPN profiles to Windows devices using Microsoft Intune is a strategic way to ensure secure remote access to your organization's network. Here's a detailed overview:"}),"\n",(0,s.jsx)(n.h3,{id:"benefits",children:"Benefits"}),"\n",(0,s.jsxs)(n.ol,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Enhanced Security"}),": VPN profiles ensure that data transmitted between devices and the network is encrypted, protecting sensitive information."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Centralized Management"}),": Intune allows you to manage and deploy VPN settings from a single console, simplifying administration."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Consistency"}),": Ensures all devices have the same VPN settings, reducing configuration errors and ensuring compliance."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"User Convenience"}),": Users can connect to the VPN without manually configuring settings, improving their experience."]}),"\n"]}),"\n",(0,s.jsx)(n.h3,{id:"drawbacks",children:"Drawbacks"}),"\n",(0,s.jsxs)(n.ol,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Initial Setup Complexity"}),": Configuring VPN profiles, especially with advanced security settings, can be complex and time-consuming."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Maintenance"}),": Ongoing maintenance is required to update VPN settings or troubleshoot connectivity issues."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Compatibility Issues"}),": Some older devices or specific network configurations might not fully support all VPN settings."]}),"\n"]}),"\n",(0,s.jsx)(n.h3,{id:"impact-on-end-users",children:"Impact on End Users"}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Seamless Connectivity"}),": Users experience seamless and secure connectivity to the corporate network without manual configuration."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Reduced Downtime"}),": Properly configured VPN profiles reduce the risk of connectivity issues, minimizing downtime."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"User Training"}),": Minimal training might be required to inform users about the new VPN setup."]}),"\n"]}),"\n",(0,s.jsx)(n.h3,{id:"tying-to-zero-trust",children:"Tying to Zero Trust"}),"\n",(0,s.jsx)(n.p,{children:"Zero Trust is a security model that assumes no implicit trust and continuously verifies every request. Deploying VPN profiles through Intune aligns with Zero Trust principles by:"}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Ensuring Secure Access"}),": VPN profiles enforce secure connections, ensuring only authorized devices can access the network."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Continuous Verification"}),": Regularly updated VPN settings help maintain secure access, aligning with the continuous verification aspect of Zero Trust."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Reducing Attack Surface"}),": By managing VPN settings centrally, you reduce the risk of misconfigurations that could be exploited."]}),"\n"]}),"\n",(0,s.jsx)(n.p,{children:"Would you like more details on any specific aspect of this process?"}),"\n",(0,s.jsxs)(n.p,{children:["Source: Conversation with Copilot, 7/30/2024\n(1) Add VPN settings to devices in Microsoft Intune | Microsoft Learn. ",(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/configuration/vpn-settings-configure",children:"https://learn.microsoft.com/en-us/mem/intune/configuration/vpn-settings-configure"}),".\n(2) Windows 10/11 VPN settings in Microsoft Intune. ",(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/configuration/vpn-settings-windows-10",children:"https://learn.microsoft.com/en-us/mem/intune/configuration/vpn-settings-windows-10"}),".\n(3) Deploying VPN Policies using Microsoft Intune: Deploying VPN Policy. ",(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/shows/windows-10-networking/deploying-vpn-policies-using-microsoft-intune-deploying-vpn-policy",children:"https://learn.microsoft.com/en-us/shows/windows-10-networking/deploying-vpn-policies-using-microsoft-intune-deploying-vpn-policy"}),".\n(4) Troubleshoot VPN profile issues - Intune | Microsoft Learn. ",(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/troubleshoot/mem/intune/device-configuration/troubleshoot-vpn-profiles",children:"https://learn.microsoft.com/en-us/troubleshoot/mem/intune/device-configuration/troubleshoot-vpn-profiles"}),".\n(5) Create an Intune profile for Azure VPN clients - Azure VPN Gateway. ",(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-profile-intune",children:"https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-profile-intune"}),"."]}),"\n",(0,s.jsx)(n.h2,{id:"reference",children:"Reference"}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:["Add VPN settings to devices in Microsoft Intune | Microsoft Learn. ",(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/configuration/vpn-settings-configure",children:"https://learn.microsoft.com/en-us/mem/intune/configuration/vpn-settings-configure"})]}),"\n",(0,s.jsxs)(n.li,{children:["Windows 10/11 VPN settings in Microsoft Intune. ",(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/configuration/vpn-settings-windows-10",children:"https://learn.microsoft.com/en-us/mem/intune/configuration/vpn-settings-windows-10"})]}),"\n",(0,s.jsxs)(n.li,{children:["Deploying VPN Policies using Microsoft Intune: Deploying VPN Policy. ",(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/shows/windows-10-networking/deploying-vpn-policies-using-microsoft-intune-deploying-vpn-policy",children:"https://learn.microsoft.com/en-us/shows/windows-10-networking/deploying-vpn-policies-using-microsoft-intune-deploying-vpn-policy"})]}),"\n"]})]})}function d(e={}){const{wrapper:n}={...(0,t.R)(),...e.components};return n?(0,s.jsx)(n,{...e,children:(0,s.jsx)(u,{...e})}):u(e)}},28453:(e,n,i)=>{i.d(n,{R:()=>r,x:()=>c});var s=i(96540);const t={},o=s.createContext(t);function r(e){const n=s.useContext(o);return s.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function c(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(t):e.components||t:r(e.components),s.createElement(o.Provider,{value:n},e.children)}}}]);
"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[6668],{68338:(e,i,n)=>{n.r(i),n.d(i,{assets:()=>l,contentTitle:()=>o,default:()=>u,frontMatter:()=>r,metadata:()=>c,toc:()=>a});var s=n(74848),t=n(28453);const r={},o="132: MDM based policies for Wi-Fi",c={id:"workshop-guidance/devices/RMD_132",title:"132: MDM based policies for Wi-Fi",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_132.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_132",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/devices/RMD_132",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_132.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"131: MDM based policies for certs",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/devices/RMD_131"},next:{title:"133: MDM based policies for VPN",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/devices/RMD_133"}},l={},a=[{value:"Overview",id:"overview",level:2},{value:"Benefits",id:"benefits",level:3},{value:"Drawbacks",id:"drawbacks",level:3},{value:"Impact on End Users",id:"impact-on-end-users",level:3},{value:"Tying to Zero Trust",id:"tying-to-zero-trust",level:3},{value:"Reference",id:"reference",level:2}];function d(e){const i={a:"a",h1:"h1",h2:"h2",h3:"h3",header:"header",li:"li",ol:"ol",p:"p",strong:"strong",ul:"ul",...(0,t.R)(),...e.components};return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)(i.header,{children:(0,s.jsx)(i.h1,{id:"132-mdm-based-policies-for-wi-fi",children:"132: MDM based policies for Wi-Fi"})}),"\n",(0,s.jsx)(i.h2,{id:"overview",children:"Overview"}),"\n",(0,s.jsx)(i.p,{children:"Deploying Wi-Fi profiles to Windows devices using Microsoft Intune is a streamlined way to ensure that devices can securely and automatically connect to your organization's Wi-Fi network. Here's a detailed overview:"}),"\n",(0,s.jsx)(i.h3,{id:"benefits",children:"Benefits"}),"\n",(0,s.jsxs)(i.ol,{children:["\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Centralized Management"}),": Intune allows you to manage Wi-Fi settings from a single console, simplifying the deployment process."]}),"\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Consistency"}),": Ensures all devices have the same Wi-Fi settings, reducing configuration errors."]}),"\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Security"}),": Supports secure authentication methods, such as WPA2-Enterprise, enhancing network security."]}),"\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"User Convenience"}),": Users can connect to the Wi-Fi network without manually entering settings, improving their experience."]}),"\n"]}),"\n",(0,s.jsx)(i.h3,{id:"drawbacks",children:"Drawbacks"}),"\n",(0,s.jsxs)(i.ol,{children:["\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Initial Setup Complexity"}),": Configuring Wi-Fi profiles, especially with advanced security settings, can be complex."]}),"\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Maintenance"}),": Ongoing maintenance is required to update Wi-Fi settings or troubleshoot connectivity issues."]}),"\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Compatibility Issues"}),": Some older devices or specific network configurations might not fully support all Wi-Fi settings."]}),"\n"]}),"\n",(0,s.jsx)(i.h3,{id:"impact-on-end-users",children:"Impact on End Users"}),"\n",(0,s.jsxs)(i.ul,{children:["\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Seamless Connectivity"}),": Users experience seamless connectivity to the corporate Wi-Fi network without manual configuration."]}),"\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Reduced Downtime"}),": Properly configured Wi-Fi profiles reduce the risk of connectivity issues, minimizing downtime."]}),"\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"User Training"}),": Minimal training might be required to inform users about the new Wi-Fi setup."]}),"\n"]}),"\n",(0,s.jsx)(i.h3,{id:"tying-to-zero-trust",children:"Tying to Zero Trust"}),"\n",(0,s.jsx)(i.p,{children:"Zero Trust is a security model that assumes no implicit trust and continuously verifies every request. Deploying Wi-Fi profiles through Intune aligns with Zero Trust principles by:"}),"\n",(0,s.jsxs)(i.ul,{children:["\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Ensuring Secure Access"}),": Wi-Fi profiles can enforce secure authentication methods, ensuring only authorized devices connect to the network."]}),"\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Continuous Verification"}),": Regularly updated Wi-Fi settings help maintain secure access, aligning with the continuous verification aspect of Zero Trust."]}),"\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Reducing Attack Surface"}),": By managing Wi-Fi settings centrally, you reduce the risk of misconfigurations that could be exploited."]}),"\n"]}),"\n",(0,s.jsx)(i.h2,{id:"reference",children:"Reference"}),"\n",(0,s.jsxs)(i.ul,{children:["\n",(0,s.jsxs)(i.li,{children:["Create a Wi-Fi profile for devices in Microsoft Intune. ",(0,s.jsx)(i.a,{href:"https://learn.microsoft.com/en-us/mem/intune/configuration/wi-fi-settings-configure",children:"https://learn.microsoft.com/en-us/mem/intune/configuration/wi-fi-settings-configure"})]}),"\n",(0,s.jsxs)(i.li,{children:["Wi-Fi settings for Windows 10/11 devices in Microsoft Intune. ",(0,s.jsx)(i.a,{href:"https://learn.microsoft.com/en-us/mem/intune/configuration/wi-fi-settings-windows",children:"https://learn.microsoft.com/en-us/mem/intune/configuration/wi-fi-settings-windows"})]}),"\n",(0,s.jsxs)(i.li,{children:["How to Deploy WiFi Configuration Profile in Microsoft Intune. ",(0,s.jsx)(i.a,{href:"https://patrickdomingues.com/2023/09/29/how-to-deploy-wifi-configuration-profile-in-microsoft-intune/",children:"https://patrickdomingues.com/2023/09/29/how-to-deploy-wifi-configuration-profile-in-microsoft-intune/"})]}),"\n"]})]})}function u(e={}){const{wrapper:i}={...(0,t.R)(),...e.components};return i?(0,s.jsx)(i,{...e,children:(0,s.jsx)(d,{...e})}):d(e)}},28453:(e,i,n)=>{n.d(i,{R:()=>o,x:()=>c});var s=n(96540);const t={},r=s.createContext(t);function o(e){const i=s.useContext(r);return s.useMemo((function(){return"function"==typeof e?e(i):{...i,...e}}),[i,e])}function c(e){let i;return i=e.disableParentContext?"function"==typeof e.components?e.components(t):e.components||t:o(e.components),s.createElement(r.Provider,{value:i},e.children)}}}]);
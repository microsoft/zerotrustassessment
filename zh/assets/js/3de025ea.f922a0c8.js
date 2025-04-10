"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[8648],{21365:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>c,contentTitle:()=>r,default:()=>l,frontMatter:()=>o,metadata:()=>a,toc:()=>p});var s=t(74848),i=t(28453);const o={},r="124: Apps Delivery / App Compat",a={id:"workshop-guidance/devices/RMD_124",title:"124: Apps Delivery / App Compat",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_124.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_124",permalink:"/zerotrustassessment/zh/docs/workshop-guidance/devices/RMD_124",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_124.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"123: File Shares to Cloud",permalink:"/zerotrustassessment/zh/docs/workshop-guidance/devices/RMD_123"},next:{title:"125: WSUS to WUFB",permalink:"/zerotrustassessment/zh/docs/workshop-guidance/devices/RMD_125"}},c={},p=[{value:"Overview",id:"overview",level:2},{value:"Entra Join app compat",id:"entra-join-app-compat",level:3},{value:"Reference",id:"reference",level:2}];function d(e){const n={a:"a",h1:"h1",h2:"h2",h3:"h3",header:"header",li:"li",p:"p",strong:"strong",ul:"ul",...(0,i.R)(),...e.components};return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)(n.header,{children:(0,s.jsx)(n.h1,{id:"124-apps-delivery--app-compat",children:"124: Apps Delivery / App Compat"})}),"\n",(0,s.jsx)(n.h2,{id:"overview",children:"Overview"}),"\n",(0,s.jsx)(n.p,{children:"Use Intune to manage and update apps in your organization, and the principles of Zero Trust in defining an app management strategy:"}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:["\n",(0,s.jsxs)(n.p,{children:[(0,s.jsx)(n.strong,{children:"Assume Breach"})," - Regularly monitor app behavior and security events. Assume that threats may already exist and proactively detect anomalies. Keep apps up-to-date with security patches to minimize vulnerabilities. Integrate threat intelligence feeds, like ",(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/advanced-threat-protection-configure",children:"Microsoft Defender for Endpoint"}),", to identify known malicious apps or behaviors."]}),"\n"]}),"\n",(0,s.jsxs)(n.li,{children:["\n",(0,s.jsxs)(n.p,{children:[(0,s.jsx)(n.strong,{children:"Verify Explicitly"})," - Define policies for how apps are acquired, installed, and updated. Only download and install apps from trusted sources. Use a secure enterprise app catalog like ",(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/apps/apps-enterprise-app-management",children:"Enterprise Application Management with Microsofot Intune"}),"."]}),"\n"]}),"\n",(0,s.jsxs)(n.li,{children:["\n",(0,s.jsxs)(n.p,{children:[(0,s.jsx)(n.strong,{children:"Use Least-Privilege Access"})," - Allow only approved apps to run on managed devices. Limit those who can install apps on devices or add new apps to Intune. Run your users as standard user (without administrative rights) and consider ",(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/epm-overview",children:"Endpoint Privilege Management with Microsoft Intune"})," to complete tasks that require elevated privileges."]}),"\n"]}),"\n"]}),"\n",(0,s.jsx)(n.h3,{id:"entra-join-app-compat",children:"Entra Join app compat"}),"\n",(0,s.jsxs)(n.p,{children:["Most apps should continue to work on Entra Join devices as they do for traditional domain-joined devices. Learn about ",(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/solutions/cloud-native-endpoints/cloud-native-endpoints-overview",children:"Windows cloud-native endpoints"})," and review ",(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/solutions/cloud-native-endpoints/cloud-native-endpoints-known-issues",children:"Known issues and limitations with cloud-native endpoints"})," for gudiance on known app compat issues with Entra Join."]}),"\n",(0,s.jsxs)(n.p,{children:[(0,s.jsx)(n.a,{href:"https://www.microsoft.com/fasttrack/microsoft-365/app-assure",children:"Microsoft App Assure"})," is a service that helps you proactively analyze app portfolios, fix and shim apps that might require a fix, and monitor app performance and reliability on Windows 11 before and after upgrading your organization."]}),"\n",(0,s.jsx)(n.h2,{id:"reference",children:"Reference"}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsx)(n.li,{children:(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/solutions/cloud-native-endpoints/cloud-native-endpoints-overview",children:"Overview of Windows cloud-native endpoints"})}),"\n",(0,s.jsx)(n.li,{children:(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/epm-overview",children:"Endpoint Privilege Management with Microsoft Intune"})}),"\n",(0,s.jsx)(n.li,{children:(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/apps/apps-enterprise-app-management",children:"Enterprise Application Management with Microsofot Intune"})}),"\n",(0,s.jsx)(n.li,{children:(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/advanced-threat-protection-configure",children:"Microsoft Defender for Endpoint"})}),"\n"]})]})}function l(e={}){const{wrapper:n}={...(0,i.R)(),...e.components};return n?(0,s.jsx)(n,{...e,children:(0,s.jsx)(d,{...e})}):d(e)}},28453:(e,n,t)=>{t.d(n,{R:()=>r,x:()=>a});var s=t(96540);const i={},o=s.createContext(i);function r(e){const n=s.useContext(o);return s.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function a(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:r(e.components),s.createElement(o.Provider,{value:n},e.children)}}}]);
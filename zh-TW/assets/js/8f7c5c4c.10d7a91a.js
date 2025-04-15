"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[8751],{36562:(e,n,s)=>{s.r(n),s.d(n,{assets:()=>l,contentTitle:()=>o,default:()=>u,frontMatter:()=>t,metadata:()=>c,toc:()=>d});var r=s(74848),i=s(28453);const t={},o="077: VPN tunnel",c={id:"workshop-guidance/devices/RMD_077",title:"077: VPN tunnel",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_077.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_077",permalink:"/zerotrustassessment/zh-TW/docs/workshop-guidance/devices/RMD_077",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_077.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"076: App config settings",permalink:"/zerotrustassessment/zh-TW/docs/workshop-guidance/devices/RMD_076"},next:{title:"078: Tunnel based VPN access for enrolled devices",permalink:"/zerotrustassessment/zh-TW/docs/workshop-guidance/devices/RMD_078"}},l={},d=[{value:"Overview",id:"overview",level:2},{value:"Reference",id:"reference",level:2}];function a(e){const n={a:"a",h1:"h1",h2:"h2",header:"header",li:"li",ol:"ol",p:"p",strong:"strong",ul:"ul",...(0,i.R)(),...e.components};return(0,r.jsxs)(r.Fragment,{children:[(0,r.jsx)(n.header,{children:(0,r.jsx)(n.h1,{id:"077-vpn-tunnel",children:"077: VPN tunnel"})}),"\n",(0,r.jsx)(n.h2,{id:"overview",children:"Overview"}),"\n",(0,r.jsxs)(n.p,{children:["Let's dive into ",(0,r.jsx)(n.strong,{children:"Microsoft Tunnel"}),", a VPN gateway solution for ",(0,r.jsx)(n.strong,{children:"Microsoft Intune"}),". Here's what you need to know:"]}),"\n",(0,r.jsxs)(n.ol,{children:["\n",(0,r.jsxs)(n.li,{children:["\n",(0,r.jsxs)(n.p,{children:[(0,r.jsx)(n.strong,{children:"Overview of Microsoft Tunnel"}),":"]}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Purpose"}),": Microsoft Tunnel allows secure access to on-premises resources from ",(0,r.jsx)(n.strong,{children:"iOS/iPadOS"})," and ",(0,r.jsx)(n.strong,{children:"Android Enterprise"})," devices using modern authentication and ",(0,r.jsx)(n.strong,{children:"Conditional Access"}),"."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Architecture"}),": It runs in a container on a ",(0,r.jsx)(n.strong,{children:"Linux server"})," (either physical or virtual)."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Deployment Steps"}),":","\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsx)(n.li,{children:"Install Microsoft Tunnel Gateway on the Linux server."}),"\n",(0,r.jsxs)(n.li,{children:["Deploy the ",(0,r.jsx)(n.strong,{children:"Microsoft Defender for Endpoint"})," (the Tunnel client app) to devices."]}),"\n",(0,r.jsx)(n.li,{children:"Configure VPN profiles on iOS and Android devices to direct them to use the tunnel."}),"\n"]}),"\n"]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Authentication Methods"}),":","\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsxs)(n.li,{children:["Devices use ",(0,r.jsx)(n.strong,{children:"Microsoft Entra ID"})," or ",(0,r.jsx)(n.strong,{children:"Active Directory Federation Services (AD FS)"})," to authenticate to the tunnel."]}),"\n",(0,r.jsx)(n.li,{children:"Conditional Access policies evaluate device compliance before granting access."}),"\n"]}),"\n"]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Sites"}),": You can install multiple Linux servers and group them into logical units called ",(0,r.jsx)(n.strong,{children:"Sites"})," for better management."]}),"\n"]}),"\n"]}),"\n",(0,r.jsxs)(n.li,{children:["\n",(0,r.jsxs)(n.p,{children:[(0,r.jsx)(n.strong,{children:"Benefits"}),":"]}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Secure Access"}),": Provides secure access to on-premises resources."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Conditional Access"}),": Integrates with Conditional Access policies for granular control."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Per-App VPN"}),": Supports per-app VPN on iOS and Android devices."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Trusted Set of IPs"}),": Ensures access to SaaS apps from known, trusted IPs."]}),"\n"]}),"\n"]}),"\n",(0,r.jsxs)(n.li,{children:["\n",(0,r.jsxs)(n.p,{children:[(0,r.jsx)(n.strong,{children:"Drawbacks"}),":"]}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Linux Dependency"}),": Requires a Linux server for hosting the tunnel."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Complex Setup"}),": Initial setup and configuration may be complex."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"No FIPS Compliance"}),": Doesn't use FIPS-compliant algorithms."]}),"\n"]}),"\n"]}),"\n",(0,r.jsxs)(n.li,{children:["\n",(0,r.jsxs)(n.p,{children:[(0,r.jsx)(n.strong,{children:"Impact to End Users"}),":"]}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Transparent"}),": For iOS devices with Microsoft Defender configured for per-app VPNs, users don't need to manually open or sign in to the app for the tunnel to work."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"User Experience"}),": End users experience seamless access to corporate resources."]}),"\n"]}),"\n"]}),"\n",(0,r.jsxs)(n.li,{children:["\n",(0,r.jsxs)(n.p,{children:[(0,r.jsx)(n.strong,{children:"Difference from Entra App Proxy"}),":"]}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Microsoft Tunnel"}),": Provides full VPN tunneling for on-premises resources."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Entra App Proxy"}),": Focuses on secure access to SaaS apps from known IPs, without full VPN functionality."]}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,r.jsx)(n.p,{children:"Remember, Microsoft Tunnel is a powerful tool for secure connectivity, but it's essential to plan and configure it correctly to maximize its benefits!"}),"\n",(0,r.jsx)(n.h2,{id:"reference",children:"Reference"}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsxs)(n.li,{children:["Learn about the Microsoft Tunnel VPN solution for Microsoft Intune: ",(0,r.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/microsoft-tunnel-overview",children:"https://learn.microsoft.com/en-us/mem/intune/protect/microsoft-tunnel-overview"})]}),"\n",(0,r.jsxs)(n.li,{children:["Intune - Microsoft Tunnel VPN Gateway - Nathan McNulty: ",(0,r.jsx)(n.a,{href:"https://blog.nathanmcnulty.com/intune-microsoft-tunnel-vpn-gateway/",children:"https://blog.nathanmcnulty.com/intune-microsoft-tunnel-vpn-gateway/"})]}),"\n",(0,r.jsxs)(n.li,{children:["Use the Microsoft Tunnel app for iOS - Microsoft Intune. ",(0,r.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/user-help/use-microsoft-tunnel-ios",children:"https://learn.microsoft.com/en-us/mem/intune/user-help/use-microsoft-tunnel-ios"})]}),"\n"]})]})}function u(e={}){const{wrapper:n}={...(0,i.R)(),...e.components};return n?(0,r.jsx)(n,{...e,children:(0,r.jsx)(a,{...e})}):a(e)}},28453:(e,n,s)=>{s.d(n,{R:()=>o,x:()=>c});var r=s(96540);const i={},t=r.createContext(i);function o(e){const n=r.useContext(t);return r.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function c(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:o(e.components),r.createElement(t.Provider,{value:n},e.children)}}}]);
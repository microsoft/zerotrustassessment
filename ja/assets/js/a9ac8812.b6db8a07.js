"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[3780],{77523:(e,i,n)=>{n.r(i),n.d(i,{assets:()=>c,contentTitle:()=>o,default:()=>h,frontMatter:()=>r,metadata:()=>a,toc:()=>l});var s=n(74848),t=n(28453);const r={},o="166: EPM",a={id:"workshop-guidance/devices/RMD_166",title:"166: EPM",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_166.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_166",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_166",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_166.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"165: Custom Compliance Policies",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_165"},next:{title:"167: Remote Help",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_167"}},c={},l=[{value:"Overview",id:"overview",level:2},{value:"<strong>What is Microsoft Intune EPM?</strong>",id:"what-is-microsoft-intune-epm",level:3},{value:"<strong>Benefits of EPM</strong>",id:"benefits-of-epm",level:3},{value:"<strong>Drawbacks of EPM</strong>",id:"drawbacks-of-epm",level:3},{value:"<strong>Relation to Zero Trust</strong>",id:"relation-to-zero-trust",level:3},{value:"Reference",id:"reference",level:2}];function d(e){const i={a:"a",h1:"h1",h2:"h2",h3:"h3",header:"header",li:"li",ol:"ol",p:"p",strong:"strong",ul:"ul",...(0,t.R)(),...e.components};return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)(i.header,{children:(0,s.jsx)(i.h1,{id:"166-epm",children:"166: EPM"})}),"\n",(0,s.jsx)(i.h2,{id:"overview",children:"Overview"}),"\n",(0,s.jsx)(i.p,{children:"Endpoint Privilege Management (EPM) is a feature within the Microsoft Intune Suite that allows organizations to manage and control elevated privileges on endpoints. Here\u2019s a detailed look at what it is, its benefits and drawbacks, and how it relates to Zero Trust:"}),"\n",(0,s.jsx)(i.h3,{id:"what-is-microsoft-intune-epm",children:(0,s.jsx)(i.strong,{children:"What is Microsoft Intune EPM?"})}),"\n",(0,s.jsx)(i.p,{children:"EPM enables users to run as standard users (without administrator rights) while still being able to perform tasks that require elevated privileges. This is achieved through controlled privilege elevation, which allows specific tasks to be performed with administrative rights based on predefined policies\xb9."}),"\n",(0,s.jsx)(i.h3,{id:"benefits-of-epm",children:(0,s.jsx)(i.strong,{children:"Benefits of EPM"})}),"\n",(0,s.jsxs)(i.ol,{children:["\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Enhanced Security"}),": By enforcing least privilege access, EPM reduces the risk associated with users having full administrative rights, thereby minimizing potential attack surfaces."]}),"\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Productivity Maintenance"}),": Users can perform necessary tasks without needing full admin rights, which helps maintain productivity while ensuring security."]}),"\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Centralized Management"}),": IT administrators can manage privilege elevations and endpoint configurations from a single interface, simplifying the management process."]}),"\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Compliance Support"}),": Helps organizations meet compliance requirements by ensuring that only authorized tasks are performed with elevated privileges."]}),"\n"]}),"\n",(0,s.jsx)(i.h3,{id:"drawbacks-of-epm",children:(0,s.jsx)(i.strong,{children:"Drawbacks of EPM"})}),"\n",(0,s.jsxs)(i.ol,{children:["\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Complexity in Policy Configuration"}),": Setting up and managing elevation policies can be complex and may require significant administrative effort."]}),"\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Licensing Costs"}),": EPM requires an additional license beyond the standard Microsoft Intune Plan 1 license, which could increase costs for organizations."]}),"\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Limited Support for Certain Devices"}),": EPM does not support workplace-joined devices or Azure Virtual Desktop, which may limit its applicability in some environments."]}),"\n"]}),"\n",(0,s.jsx)(i.h3,{id:"relation-to-zero-trust",children:(0,s.jsx)(i.strong,{children:"Relation to Zero Trust"})}),"\n",(0,s.jsx)(i.p,{children:"Zero Trust is a security model that assumes no user or device is trustworthy by default. Microsoft Intune EPM aligns with Zero Trust principles in the following ways:"}),"\n",(0,s.jsxs)(i.ol,{children:["\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Verify Explicitly"}),": Intune continuously verifies user identities and device health before granting elevated privileges."]}),"\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Use Least Privilege Access"}),": EPM enforces least privilege access by allowing users to perform specific tasks with elevated privileges without granting full admin rights."]}),"\n",(0,s.jsxs)(i.li,{children:[(0,s.jsx)(i.strong,{children:"Assume Breach"}),": By limiting the scope and duration of elevated privileges, EPM reduces the potential impact of a security breach."]}),"\n"]}),"\n",(0,s.jsx)(i.h2,{id:"reference",children:"Reference"}),"\n",(0,s.jsxs)(i.ul,{children:["\n",(0,s.jsxs)(i.li,{children:["*Use Endpoint Privilege Management with Microsoft Intune. ",(0,s.jsx)(i.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/epm-overview",children:"https://learn.microsoft.com/en-us/mem/intune/protect/epm-overview"}),"."]}),"\n",(0,s.jsxs)(i.li,{children:["Microsoft Intune Endpoint Privilege Management. ",(0,s.jsx)(i.a,{href:"https://www.microsoft.com/en-us/security/business/endpoint-management/microsoft-intune-endpoint-privilege-management",children:"https://www.microsoft.com/en-us/security/business/endpoint-management/microsoft-intune-endpoint-privilege-management"}),"."]}),"\n"]})]})}function h(e={}){const{wrapper:i}={...(0,t.R)(),...e.components};return i?(0,s.jsx)(i,{...e,children:(0,s.jsx)(d,{...e})}):d(e)}},28453:(e,i,n)=>{n.d(i,{R:()=>o,x:()=>a});var s=n(96540);const t={},r=s.createContext(t);function o(e){const i=s.useContext(r);return s.useMemo((function(){return"function"==typeof e?e(i):{...i,...e}}),[i,e])}function a(e){let i;return i=e.disableParentContext?"function"==typeof e.components?e.components(t):e.components||t:o(e.components),s.createElement(r.Provider,{value:i},e.children)}}}]);
"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[4413],{50603:(e,n,s)=>{s.r(n),s.d(n,{assets:()=>a,contentTitle:()=>o,default:()=>u,frontMatter:()=>r,metadata:()=>l,toc:()=>c});var i=s(74848),t=s(28453);const r={},o="140: Cloud LAPS",l={id:"workshop-guidance/devices/RMD_140",title:"140: Cloud LAPS",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_140.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_140",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/devices/RMD_140",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_140.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"139: Security Baselines",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/devices/RMD_139"},next:{title:"141: Update Rings",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/devices/RMD_141"}},a={},c=[{value:"Overview",id:"overview",level:2},{value:"Benefits",id:"benefits",level:3},{value:"Drawbacks",id:"drawbacks",level:3},{value:"Impact on End Users",id:"impact-on-end-users",level:3},{value:"Steps to Deploy Cloud LAPS",id:"steps-to-deploy-cloud-laps",level:3},{value:"Tying to Zero Trust",id:"tying-to-zero-trust",level:3},{value:"Reference",id:"reference",level:2}];function d(e){const n={a:"a",h1:"h1",h2:"h2",h3:"h3",header:"header",li:"li",ol:"ol",p:"p",strong:"strong",ul:"ul",...(0,t.R)(),...e.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(n.header,{children:(0,i.jsx)(n.h1,{id:"140-cloud-laps",children:"140: Cloud LAPS"})}),"\n",(0,i.jsx)(n.h2,{id:"overview",children:"Overview"}),"\n",(0,i.jsx)(n.p,{children:"Cloud Local Administrator Password Solution (LAPS) for Windows devices in Microsoft Intune is a powerful tool for managing local administrator passwords securely. Here's a detailed overview:"}),"\n",(0,i.jsx)(n.h3,{id:"benefits",children:"Benefits"}),"\n",(0,i.jsxs)(n.ol,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Enhanced Security"}),": Cloud LAPS ensures that each device has a unique, complex local administrator password, reducing the risk of unauthorized access."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Centralized Management"}),": Intune provides a centralized platform for managing local admin passwords, simplifying administration."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Automated Password Rotation"}),": Automatically rotates passwords on a schedule, ensuring they remain secure."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Compliance"}),": Helps meet regulatory requirements by ensuring secure management of local admin accounts."]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"drawbacks",children:"Drawbacks"}),"\n",(0,i.jsxs)(n.ol,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Initial Setup Complexity"}),": Configuring Cloud LAPS can be complex and time-consuming, especially for large organizations."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Maintenance"}),": Ongoing maintenance is required to ensure the system remains secure and functional."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Compatibility Issues"}),": Potential compatibility issues with older devices or systems that do not fully support Cloud LAPS."]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"impact-on-end-users",children:"Impact on End Users"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Improved Security"}),": Users benefit from enhanced security without needing to take additional actions."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Minimal Disruption"}),": Properly configured Cloud LAPS can be deployed with minimal disruption to users."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Recovery Support"}),": Users have access to recovery options if they forget their local admin password."]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"steps-to-deploy-cloud-laps",children:"Steps to Deploy Cloud LAPS"}),"\n",(0,i.jsxs)(n.ol,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Enable Cloud LAPS"}),': In the Azure Active Directory (AAD) or Microsoft Entra Admin portal, navigate to Devices > All devices > Device Settings. Toggle the option to enable Microsoft Entra Local Administrator Password Solution (LAPS) to "Yes" and save.']}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Configure Intune Policies"}),": In Intune, create a new policy for account protection and configure the LAPS settings, including password complexity and rotation schedule."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Assign Policies"}),": Assign the LAPS policy to the appropriate groups of devices or users."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Monitor and Adjust"}),": Continuously monitor the deployment and make adjustments as needed."]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"tying-to-zero-trust",children:"Tying to Zero Trust"}),"\n",(0,i.jsx)(n.p,{children:"Zero Trust is a security model that assumes no implicit trust and continuously verifies every request. Deploying Cloud LAPS through Intune aligns with Zero Trust principles by:"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Ensuring Secure Access"}),": Cloud LAPS enforces unique, complex passwords for local admin accounts, ensuring only authorized access."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Continuous Verification"}),": Regularly updated passwords help maintain secure access, aligning with the continuous verification aspect of Zero Trust."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Reducing Attack Surface"}),": By managing local admin passwords centrally, Cloud LAPS reduces the potential attack surface."]}),"\n"]}),"\n",(0,i.jsx)(n.h2,{id:"reference",children:"Reference"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:["Manage Windows LAPS with Microsoft Intune policies: ",(0,i.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/windows-laps-overview",children:"https://learn.microsoft.com/en-us/mem/intune/protect/windows-laps-overview"})]}),"\n",(0,i.jsxs)(n.li,{children:["External Blog: Set up Windows LAPS with Intune: A Step-by-Step Guide - Prajwal Desai. ",(0,i.jsx)(n.a,{href:"https://www.prajwaldesai.com/set-up-windows-laps-with-intune/",children:"https://www.prajwaldesai.com/set-up-windows-laps-with-intune/"})]}),"\n",(0,i.jsxs)(n.li,{children:["External Blog: Implement LAPS With Intune: A Comprehensive Guide - CloudInfra. ",(0,i.jsx)(n.a,{href:"https://cloudinfra.net/implement-laps-with-intune-a-comprehensive-guide/",children:"https://cloudinfra.net/implement-laps-with-intune-a-comprehensive-guide/"})]}),"\n"]})]})}function u(e={}){const{wrapper:n}={...(0,t.R)(),...e.components};return n?(0,i.jsx)(n,{...e,children:(0,i.jsx)(d,{...e})}):d(e)}},28453:(e,n,s)=>{s.d(n,{R:()=>o,x:()=>l});var i=s(96540);const t={},r=i.createContext(t);function o(e){const n=i.useContext(r);return i.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function l(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(t):e.components||t:o(e.components),i.createElement(r.Provider,{value:n},e.children)}}}]);
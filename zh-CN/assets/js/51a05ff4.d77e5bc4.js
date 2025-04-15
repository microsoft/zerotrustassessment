"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[9857],{71620:(e,n,s)=>{s.r(n),s.d(n,{assets:()=>l,contentTitle:()=>o,default:()=>u,frontMatter:()=>t,metadata:()=>c,toc:()=>a});var i=s(74848),r=s(28453);const t={},o="097: Userless Enrollment",c={id:"workshop-guidance/devices/RMD_097",title:"097: Userless Enrollment",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_097.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_097",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/devices/RMD_097",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_097.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"096: User enrollment",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/devices/RMD_096"},next:{title:"098: Android Enterprise",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/devices/RMD_098"}},l={},a=[{value:"Overview",id:"overview",level:2},{value:"Benefits",id:"benefits",level:2},{value:"Drawbacks",id:"drawbacks",level:2},{value:"Impact on End Users",id:"impact-on-end-users",level:2},{value:"Relation to Zero Trust",id:"relation-to-zero-trust",level:2},{value:"Reference",id:"reference",level:2}];function d(e){const n={a:"a",h1:"h1",h2:"h2",header:"header",li:"li",p:"p",strong:"strong",ul:"ul",...(0,r.R)(),...e.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(n.header,{children:(0,i.jsx)(n.h1,{id:"097-userless-enrollment",children:"097: Userless Enrollment"})}),"\n",(0,i.jsx)(n.h2,{id:"overview",children:"Overview"}),"\n",(0,i.jsx)(n.h2,{id:"benefits",children:"Benefits"}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Simplified Management:"})," Userless enrollment allows IT administrators to manage devices without associating them with specific users. This is ideal for shared devices used in environments like kiosks or frontline work"]}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Consistency:"})," Devices can be configured with a standard set of apps and policies, ensuring a consistent experience across all devices"]}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Security:"})," Devices are enrolled with security policies that protect corporate data, even when multiple users access the same device"]}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Efficiency:"})," Streamlines the deployment process, as devices can be quickly set up and deployed without needing individual user accounts"]}),"\n",(0,i.jsx)(n.h2,{id:"drawbacks",children:"Drawbacks"}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Limited Personalization:"})," Since devices are not tied to individual users, personalization options are limited. This can impact user experience for tasks requiring personal settings"]}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"App Compatibility:"})," Some apps that require user-specific data, like email clients, may not function optimally on userless devices"]}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Complex Setup:"})," Initial setup and configuration can be complex, requiring careful planning and execution"]}),"\n",(0,i.jsx)(n.h2,{id:"impact-on-end-users",children:"Impact on End Users"}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Shared Use:"})," Devices are typically shared among multiple users, which can be beneficial in environments like retail or healthcare where devices are used for specific tasks"]}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Access Control:"})," Users might need to sign in and out of apps frequently, which can be less convenient compared to having a dedicated device"]}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Training:"})," Users may require training to understand how to use shared devices effectively and securely"]}),"\n",(0,i.jsx)(n.h2,{id:"relation-to-zero-trust",children:"Relation to Zero Trust"}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Device Compliance:"})," Userless enrollment supports the Zero Trust principle by ensuring that every device accessing corporate resources is compliant with security policies"]}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Least Privilege:"}),"  Devices are configured to provide only the necessary access and functionality, aligning with the Zero Trust principle of least privilege"]}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Continuous Monitoring:"})," Intune continuously monitors enrolled devices for compliance, ensuring they remain secure and meet organizational policies"]}),"\n",(0,i.jsx)(n.h2,{id:"reference",children:"Reference"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:["End-to-end guide for configuring Android enterprise devices in Microsoft Intune ",(0,i.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/troubleshoot/mem/intune/device-enrollment/configure-android-enterprise-devices-intune",children:"https://learn.microsoft.com/en-us/troubleshoot/mem/intune/device-enrollment/configure-android-enterprise-devices-intune"})]}),"\n",(0,i.jsxs)(n.li,{children:["Set up Intune enrollment for Android (AOSP) corporate-owned userless devices ",(0,i.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/enrollment/android-aosp-corporate-owned-userless-enroll",children:"https://learn.microsoft.com/en-us/mem/intune/enrollment/android-aosp-corporate-owned-userless-enroll"})]}),"\n"]})]})}function u(e={}){const{wrapper:n}={...(0,r.R)(),...e.components};return n?(0,i.jsx)(n,{...e,children:(0,i.jsx)(d,{...e})}):d(e)}},28453:(e,n,s)=>{s.d(n,{R:()=>o,x:()=>c});var i=s(96540);const r={},t=i.createContext(r);function o(e){const n=i.useContext(t);return i.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function c(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(r):e.components||r:o(e.components),i.createElement(t.Provider,{value:n},e.children)}}}]);
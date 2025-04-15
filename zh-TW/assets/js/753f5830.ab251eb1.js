"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[3770],{13779:(e,n,s)=>{s.r(n),s.d(n,{assets:()=>c,contentTitle:()=>o,default:()=>h,frontMatter:()=>r,metadata:()=>a,toc:()=>l});var t=s(74848),i=s(28453);const r={},o="184: Native update management",a={id:"workshop-guidance/devices/RMD_184",title:"184: Native update management",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_184.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_184",permalink:"/zerotrustassessment/zh-TW/docs/workshop-guidance/devices/RMD_184",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_184.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"183: Local account management",permalink:"/zerotrustassessment/zh-TW/docs/workshop-guidance/devices/RMD_183"},next:{title:"185: Remote Assist",permalink:"/zerotrustassessment/zh-TW/docs/workshop-guidance/devices/RMD_185"}},c={},l=[{value:"Overview",id:"overview",level:2},{value:"Steps to Deploy Native Update Management",id:"steps-to-deploy-native-update-management",level:3},{value:"Benefits",id:"benefits",level:3},{value:"Drawbacks",id:"drawbacks",level:3},{value:"Impact on End Users",id:"impact-on-end-users",level:3},{value:"Tying to Zero Trust",id:"tying-to-zero-trust",level:3},{value:"Reference",id:"reference",level:2}];function d(e){const n={a:"a",h1:"h1",h2:"h2",h3:"h3",header:"header",li:"li",ol:"ol",p:"p",strong:"strong",ul:"ul",...(0,i.R)(),...e.components};return(0,t.jsxs)(t.Fragment,{children:[(0,t.jsx)(n.header,{children:(0,t.jsx)(n.h1,{id:"184-native-update-management",children:"184: Native update management"})}),"\n",(0,t.jsx)(n.h2,{id:"overview",children:"Overview"}),"\n",(0,t.jsx)(n.p,{children:"Managing native updates for macOS devices using Microsoft Intune involves several steps to ensure devices are up-to-date, secure, and compliant. Here's a detailed overview:"}),"\n",(0,t.jsx)(n.h3,{id:"steps-to-deploy-native-update-management",children:"Steps to Deploy Native Update Management"}),"\n",(0,t.jsxs)(n.ol,{children:["\n",(0,t.jsxs)(n.li,{children:["\n",(0,t.jsxs)(n.p,{children:[(0,t.jsx)(n.strong,{children:"Prerequisites"}),":"]}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsx)(n.li,{children:"Ensure you have the necessary licenses for Microsoft Intune."}),"\n",(0,t.jsx)(n.li,{children:"Verify that macOS devices are enrolled in Intune and connected to the internet."}),"\n"]}),"\n"]}),"\n",(0,t.jsxs)(n.li,{children:["\n",(0,t.jsxs)(n.p,{children:[(0,t.jsx)(n.strong,{children:"Configure Update Policies"}),":"]}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsx)(n.li,{children:"Sign in to the Intune admin center."}),"\n",(0,t.jsxs)(n.li,{children:["Navigate to ",(0,t.jsx)(n.strong,{children:"Devices > Update policies for macOS > Create profile"}),"."]}),"\n",(0,t.jsxs)(n.li,{children:["On the ",(0,t.jsx)(n.strong,{children:"Basics"})," tab, specify a name and description for the policy."]}),"\n",(0,t.jsxs)(n.li,{children:["On the ",(0,t.jsx)(n.strong,{children:"Update policy settings"})," tab, configure the following options:","\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Critical, Firmware, Configuration file, and All other updates"}),": Choose actions like download and install, download only, install immediately, notify only, or install later."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Max User Deferrals"}),": Specify the maximum number of times a user can postpone an update."]}),"\n"]}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,t.jsxs)(n.li,{children:["\n",(0,t.jsxs)(n.p,{children:[(0,t.jsx)(n.strong,{children:"Assign Update Policies"}),":"]}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsx)(n.li,{children:"Assign the update policies to the relevant device groups to ensure they are applied across all targeted macOS devices."}),"\n"]}),"\n"]}),"\n",(0,t.jsxs)(n.li,{children:["\n",(0,t.jsxs)(n.p,{children:[(0,t.jsx)(n.strong,{children:"Monitor Update Status"}),":"]}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsx)(n.li,{children:"Use the Intune admin center to monitor the update status of devices."}),"\n",(0,t.jsx)(n.li,{children:"Check for any issues and troubleshoot as needed\xb2."}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,t.jsx)(n.h3,{id:"benefits",children:"Benefits"}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Enhanced Security"}),": Ensures devices are up-to-date with the latest security patches and updates."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Centralized Management"}),": Simplifies the management of software updates across all macOS devices from a single console."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Compliance"}),": Helps ensure devices comply with organizational policies and regulatory requirements."]}),"\n"]}),"\n",(0,t.jsx)(n.h3,{id:"drawbacks",children:"Drawbacks"}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Complex Setup"}),": Initial configuration and setup can be complex and time-consuming."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Dependency on Internet"}),": Updates require devices to be connected to the internet."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"User Experience"}),": Users might experience interruptions during the update process."]}),"\n"]}),"\n",(0,t.jsx)(n.h3,{id:"impact-on-end-users",children:"Impact on End Users"}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Performance"}),": Users might notice a slight decrease in performance during updates."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Notifications"}),": Users will receive notifications related to software updates."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Seamless Updates"}),": Users benefit from automated updates, reducing the need for manual intervention."]}),"\n"]}),"\n",(0,t.jsx)(n.h3,{id:"tying-to-zero-trust",children:"Tying to Zero Trust"}),"\n",(0,t.jsx)(n.p,{children:"Deploying native update management for macOS devices aligns with the Zero Trust security model by ensuring that:"}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Continuous Verification"}),": Every access request and action is continuously verified, regardless of where the request originates."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Least Privilege Access"}),": Users and devices are granted the minimum level of access necessary to perform their tasks."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Assume Breach"}),": The system is designed with the assumption that a breach has already occurred, ensuring robust detection and response mechanisms."]}),"\n"]}),"\n",(0,t.jsx)(n.h2,{id:"reference",children:"Reference"}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:["Use Microsoft Intune policies to manage macOS software updates. ",(0,t.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/software-updates-macos",children:"https://learn.microsoft.com/en-us/mem/intune/protect/software-updates-macos"}),"."]}),"\n",(0,t.jsxs)(n.li,{children:["Admin guide and checklist for macOS software updates. ",(0,t.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/software-updates-guide-macos",children:"https://learn.microsoft.com/en-us/mem/intune/protect/software-updates-guide-macos"}),"."]}),"\n",(0,t.jsxs)(n.li,{children:["Use the settings catalog to configure managed software updates. ",(0,t.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/managed-software-updates-ios-macos",children:"https://learn.microsoft.com/en-us/mem/intune/protect/managed-software-updates-ios-macos"}),"."]}),"\n",(0,t.jsxs)(n.li,{children:["10 ways Microsoft Intune improves Apple device management. ",(0,t.jsx)(n.a,{href:"https://techcommunity.microsoft.com/t5/microsoft-intune-blog/10-ways-microsoft-intune-improves-apple-device-management/ba-p/3766718",children:"https://techcommunity.microsoft.com/t5/microsoft-intune-blog/10-ways-microsoft-intune-improves-apple-device-management/ba-p/3766718"}),"."]}),"\n"]})]})}function h(e={}){const{wrapper:n}={...(0,i.R)(),...e.components};return n?(0,t.jsx)(n,{...e,children:(0,t.jsx)(d,{...e})}):d(e)}},28453:(e,n,s)=>{s.d(n,{R:()=>o,x:()=>a});var t=s(96540);const i={},r=t.createContext(i);function o(e){const n=t.useContext(r);return t.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function a(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:o(e.components),t.createElement(r.Provider,{value:n},e.children)}}}]);
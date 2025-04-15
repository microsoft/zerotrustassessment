"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[6927],{87776:(e,n,s)=>{s.r(n),s.d(n,{assets:()=>l,contentTitle:()=>o,default:()=>h,frontMatter:()=>r,metadata:()=>c,toc:()=>d});var t=s(74848),i=s(28453);const r={},o="181: Remote actions",c={id:"workshop-guidance/devices/RMD_181",title:"181: Remote actions",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_181.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_181",permalink:"/zerotrustassessment/ko/docs/workshop-guidance/devices/RMD_181",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_181.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"180: App management",permalink:"/zerotrustassessment/ko/docs/workshop-guidance/devices/RMD_180"},next:{title:"182: FileVault encryption",permalink:"/zerotrustassessment/ko/docs/workshop-guidance/devices/RMD_182"}},l={},d=[{value:"Overview",id:"overview",level:2},{value:"Steps to Deploy Remote Actions",id:"steps-to-deploy-remote-actions",level:3},{value:"Benefits",id:"benefits",level:3},{value:"Drawbacks",id:"drawbacks",level:3},{value:"Impact on End Users",id:"impact-on-end-users",level:3},{value:"Tying to Zero Trust",id:"tying-to-zero-trust",level:3},{value:"Reference",id:"reference",level:2}];function a(e){const n={a:"a",h1:"h1",h2:"h2",h3:"h3",header:"header",li:"li",ol:"ol",p:"p",strong:"strong",ul:"ul",...(0,i.R)(),...e.components};return(0,t.jsxs)(t.Fragment,{children:[(0,t.jsx)(n.header,{children:(0,t.jsx)(n.h1,{id:"181-remote-actions",children:"181: Remote actions"})}),"\n",(0,t.jsx)(n.h2,{id:"overview",children:"Overview"}),"\n",(0,t.jsx)(n.p,{children:"Managing macOS devices remotely using Microsoft Intune involves several steps and offers various benefits and drawbacks. Here's a detailed overview:"}),"\n",(0,t.jsx)(n.h3,{id:"steps-to-deploy-remote-actions",children:"Steps to Deploy Remote Actions"}),"\n",(0,t.jsxs)(n.ol,{children:["\n",(0,t.jsxs)(n.li,{children:["\n",(0,t.jsxs)(n.p,{children:[(0,t.jsx)(n.strong,{children:"Prerequisites"}),":"]}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsx)(n.li,{children:"Ensure you have the necessary licenses for Microsoft Intune."}),"\n",(0,t.jsx)(n.li,{children:"Verify that macOS devices are enrolled in Intune and connected to the internet."}),"\n"]}),"\n"]}),"\n",(0,t.jsxs)(n.li,{children:["\n",(0,t.jsxs)(n.p,{children:[(0,t.jsx)(n.strong,{children:"Access the Intune Admin Center"}),":"]}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsx)(n.li,{children:"Sign in to the Intune admin center."}),"\n",(0,t.jsxs)(n.li,{children:["Navigate to ",(0,t.jsx)(n.strong,{children:"Devices > All devices"})," and select the macOS device you want to manage."]}),"\n"]}),"\n"]}),"\n",(0,t.jsxs)(n.li,{children:["\n",(0,t.jsxs)(n.p,{children:[(0,t.jsx)(n.strong,{children:"Available Remote Actions"}),":"]}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Restart"}),": Remotely restart the device."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Wipe"}),": Erase all data on the device and reset it to factory settings."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Lock"}),": Lock the device to prevent unauthorized access."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Reset Password"}),": Reset the user's password."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Sync"}),": Force the device to check in with Intune to receive the latest policies and configurations."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Collect Diagnostics"}),": Gather diagnostic logs for troubleshooting."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Remote Help"}),": Start a remote assistance session to help users with issues."]}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,t.jsx)(n.h3,{id:"benefits",children:"Benefits"}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Enhanced Control"}),": Provides IT administrators with the ability to manage and troubleshoot devices remotely, reducing downtime."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Improved Security"}),": Allows for quick responses to security incidents, such as wiping a lost or stolen device."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Efficiency"}),": Streamlines device management processes, saving time and resources."]}),"\n"]}),"\n",(0,t.jsx)(n.h3,{id:"drawbacks",children:"Drawbacks"}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Complex Setup"}),": Initial configuration and setup can be complex and time-consuming."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Dependency on Internet"}),": Remote actions require the device to be connected to the internet."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"User Disruption"}),": Some actions, like restarting or wiping a device, can disrupt the user's work."]}),"\n"]}),"\n",(0,t.jsx)(n.h3,{id:"impact-on-end-users",children:"Impact on End Users"}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Performance"}),": Users might notice a slight decrease in performance during remote actions."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Notifications"}),": Users will receive notifications related to remote actions, such as password resets or device locks."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Assistance"}),": Remote help sessions can provide timely support, improving user satisfaction."]}),"\n"]}),"\n",(0,t.jsx)(n.h3,{id:"tying-to-zero-trust",children:"Tying to Zero Trust"}),"\n",(0,t.jsx)(n.p,{children:"Deploying remote actions for macOS devices aligns with the Zero Trust security model by ensuring that:"}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Continuous Verification"}),": Every access request and action is continuously verified, regardless of where the request originates."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Least Privilege Access"}),": Users and devices are granted the minimum level of access necessary to perform their tasks."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Assume Breach"}),": The system is designed with the assumption that a breach has already occurred, ensuring robust detection and response mechanisms."]}),"\n"]}),"\n",(0,t.jsx)(n.h2,{id:"reference",children:"Reference"}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:["Deployment guide to manage macOS devices in Microsoft Intune. ",(0,t.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/fundamentals/deployment-guide-platform-macos",children:"https://learn.microsoft.com/en-us/mem/intune/fundamentals/deployment-guide-platform-macos"}),"."]}),"\n",(0,t.jsxs)(n.li,{children:["Run remote actions on devices with Microsoft Intune. ",(0,t.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/intune/intune/remote-actions/device-management",children:"https://learn.microsoft.com/en-us/intune/intune/remote-actions/device-management"}),"."]}),"\n",(0,t.jsxs)(n.li,{children:["Exploring Microsoft Intune's Remote Help on macOS: A Hands-On Guide. ",(0,t.jsx)(n.a,{href:"https://www.intuneirl.com/exploring-microsoft-intune-remote-help-on-macos/",children:"https://www.intuneirl.com/exploring-microsoft-intune-remote-help-on-macos/"}),"."]}),"\n",(0,t.jsxs)(n.li,{children:["Microsoft Intune Remote Help adds full control for Mac. ",(0,t.jsx)(n.a,{href:"https://techcommunity.microsoft.com/t5/microsoft-intune-blog/microsoft-intune-remote-help-adds-full-control-for-mac/ba-p/4120480",children:"https://techcommunity.microsoft.com/t5/microsoft-intune-blog/microsoft-intune-remote-help-adds-full-control-for-mac/ba-p/4120480"}),"."]}),"\n"]})]})}function h(e={}){const{wrapper:n}={...(0,i.R)(),...e.components};return n?(0,t.jsx)(n,{...e,children:(0,t.jsx)(a,{...e})}):a(e)}},28453:(e,n,s)=>{s.d(n,{R:()=>o,x:()=>c});var t=s(96540);const i={},r=t.createContext(i);function o(e){const n=t.useContext(r);return t.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function c(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:o(e.components),t.createElement(r.Provider,{value:n},e.children)}}}]);
"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[2621],{83988:(e,n,i)=>{i.r(n),i.d(n,{assets:()=>c,contentTitle:()=>o,default:()=>u,frontMatter:()=>s,metadata:()=>d,toc:()=>a});var r=i(74848),t=i(28453);const s={},o="084: Android Device Administrator Retirement",d={id:"workshop-guidance/devices/RMD_084",title:"084: Android Device Administrator Retirement",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_084.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_084",permalink:"/zerotrustassessment/ko/docs/workshop-guidance/devices/RMD_084",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_084.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"083: Review app provisioning strategy",permalink:"/zerotrustassessment/ko/docs/workshop-guidance/devices/RMD_083"},next:{title:"085: Offboarding Devices",permalink:"/zerotrustassessment/ko/docs/workshop-guidance/devices/RMD_085"}},c={},a=[{value:"Overview",id:"overview",level:2},{value:"Reference",id:"reference",level:2}];function l(e){const n={a:"a",h1:"h1",h2:"h2",header:"header",li:"li",ol:"ol",p:"p",strong:"strong",ul:"ul",...(0,t.R)(),...e.components};return(0,r.jsxs)(r.Fragment,{children:[(0,r.jsx)(n.header,{children:(0,r.jsx)(n.h1,{id:"084-android-device-administrator-retirement",children:"084: Android Device Administrator Retirement"})}),"\n",(0,r.jsx)(n.h2,{id:"overview",children:"Overview"}),"\n",(0,r.jsxs)(n.ol,{children:["\n",(0,r.jsxs)(n.li,{children:["\n",(0,r.jsxs)(n.p,{children:[(0,r.jsx)(n.strong,{children:"Background"}),":"]}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsx)(n.li,{children:"Google deprecated Android device administrator management back in 2020 and has been encouraging users to move away from it since 2017."}),"\n",(0,r.jsx)(n.li,{children:"Microsoft Intune will end support for device administrator management on devices with access to Google Mobile Services (GMS) starting from December 31, 2024."}),"\n",(0,r.jsx)(n.li,{children:"Until that time, Intune will continue supporting device administrator management on devices running Android 14 or earlier."}),"\n"]}),"\n"]}),"\n",(0,r.jsxs)(n.li,{children:["\n",(0,r.jsxs)(n.p,{children:[(0,r.jsx)(n.strong,{children:"Impact on Devices with GMS"}),":"]}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsxs)(n.li,{children:["After Intune ends support for Android device administrator:","\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsx)(n.li,{children:"Users won't be able to enroll devices using Android device administrator."}),"\n",(0,r.jsx)(n.li,{children:"Intune won't provide updates, bug fixes, or security fixes for Android device administrator management."}),"\n",(0,r.jsx)(n.li,{children:"Intune technical support won't assist with these devices."}),"\n"]}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,r.jsxs)(n.li,{children:["\n",(0,r.jsxs)(n.p,{children:[(0,r.jsx)(n.strong,{children:"Impact on Devices without GMS"}),":"]}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsx)(n.li,{children:"Microsoft Teams-certified Android devices will be migrated to Android Open Source Project (AOSP) management in Intune via a firmware update in Q3 2024."}),"\n",(0,r.jsx)(n.li,{children:"Policies won't be migrated automatically, so IT admins need to create new policies for AOSP management."}),"\n",(0,r.jsx)(n.li,{children:"For other devices without GMS access running Android 15 or earlier, Intune will continue allowing device administrator enrollment but with limited support. Note that Google's device administrator deprecation could impact functionality in the future."}),"\n"]}),"\n"]}),"\n",(0,r.jsxs)(n.li,{children:["\n",(0,r.jsxs)(n.p,{children:[(0,r.jsx)(n.strong,{children:"Alternatives"}),":"]}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsxs)(n.li,{children:["Intune offers several alternatives to device administrator:","\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsx)(n.li,{children:"Android Enterprise management (for devices with GMS access)."}),"\n",(0,r.jsx)(n.li,{children:"Mobile application management (MAM) for app-level control."}),"\n",(0,r.jsx)(n.li,{children:"Consider reviewing the list of countries where Android Enterprise is available\xb9."}),"\n"]}),"\n"]}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,r.jsx)(n.p,{children:"In summary, while the retirement of Android device administrator brings some limitations, Intune provides alternative management options to ensure a smooth transition for organizations and end users."}),"\n",(0,r.jsx)(n.h2,{id:"reference",children:"Reference"}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsx)(n.li,{children:(0,r.jsx)(n.a,{href:"https://techcommunity.microsoft.com/t5/intune-customer-success/intune-ending-support-for-android-device-administrator-on/ba-p/3915443",children:"https://techcommunity.microsoft.com/t5/intune-customer-success/intune-ending-support-for-android-device-administrator-on/ba-p/3915443"})}),"\n",(0,r.jsxs)(n.li,{children:["Blog:  Intune End of Support for Android Device Administrator. ",(0,r.jsx)(n.a,{href:"https://www.anoopcnair.com/intune-end-of-support-for-android-device-admin/",children:"https://www.anoopcnair.com/intune-end-of-support-for-android-device-admin/"})]}),"\n"]})]})}function u(e={}){const{wrapper:n}={...(0,t.R)(),...e.components};return n?(0,r.jsx)(n,{...e,children:(0,r.jsx)(l,{...e})}):l(e)}},28453:(e,n,i)=>{i.d(n,{R:()=>o,x:()=>d});var r=i(96540);const t={},s=r.createContext(t);function o(e){const n=r.useContext(s);return r.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function d(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(t):e.components||t:o(e.components),r.createElement(s.Provider,{value:n},e.children)}}}]);
"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[7940],{13263:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>c,contentTitle:()=>r,default:()=>l,frontMatter:()=>s,metadata:()=>a,toc:()=>p});var i=t(74848),o=t(28453);const s={},r="034: Review App config vs App protection policies",a={id:"workshop-guidance/devices/RMD_034",title:"034: Review App config vs App protection policies",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_034.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_034",permalink:"/zerotrustassessment/ko/docs/workshop-guidance/devices/RMD_034",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_034.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"033: Review security, compliance, resource access requirements (Certs/Wi-Fi/VPN)",permalink:"/zerotrustassessment/ko/docs/workshop-guidance/devices/RMD_033"},next:{title:"035: Data protection",permalink:"/zerotrustassessment/ko/docs/workshop-guidance/devices/RMD_035"}},c={},p=[{value:"Overview",id:"overview",level:2},{value:"Reference",id:"reference",level:2}];function d(e){const n={a:"a",h1:"h1",h2:"h2",header:"header",li:"li",p:"p",strong:"strong",ul:"ul",...(0,o.R)(),...e.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(n.header,{children:(0,i.jsx)(n.h1,{id:"034-review-app-config-vs-app-protection-policies",children:"034: Review App config vs App protection policies"})}),"\n",(0,i.jsx)(n.h2,{id:"overview",children:"Overview"}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Intune app protection policies (APP)"}),' are rules that ensure an organization\'s data remains safe or contained in a managed app. These policies allow you to control how data is accessed and shared by apps on mobile devices. A policy can be a rule that is enforced when the user attempts to access or move "corporate" data, or a set of actions that are prohibited or monitored when the user is inside the app. A managed app in Intune is a protected app that has Intune app protection policies applied to it and is managed by Intune.']}),"\n",(0,i.jsx)(n.p,{children:"There are several benefits of using Intune app protection policies, including protecting corporate data on mobile devices without requiring device enrollment and controlling how data is accessed and shared by apps on mobile devices."}),"\n",(0,i.jsx)(n.p,{children:"Examples of using app protection policies with Microsoft Intune include:"}),"\n",(0,i.jsx)(n.p,{children:"Requiring a PIN or fingerprint to access corporate email on a mobile device Preventing users from copying and pasting corporate data into personal apps Restricting access to corporate data to only approved apps"}),"\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"App configuration policies"})," can help you eliminate app setup problems by letting you assign configuration settings to a policy that is assigned to end-users before they run the app. The settings are then supplied automatically when the app is configured on the end-users device, and end-users don't need to take action. The configuration settings are unique for each app."]}),"\n",(0,i.jsx)(n.p,{children:"You can create and use app configuration policies to provide configuration settings for both iOS/iPadOS or Android apps. These configuration settings allow an app to be customized by using app configuration and management. The configuration policy settings are used when the app checks for these settings, typically the first time the app is run."}),"\n",(0,i.jsx)(n.p,{children:"An app configuration setting, for example, might require you to specify any of the following details:"}),"\n",(0,i.jsx)(n.p,{children:"A custom port number Language settings Security settings Branding settings such as a company logo"}),"\n",(0,i.jsx)(n.h2,{id:"reference",children:"Reference"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsx)(n.li,{children:(0,i.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/apps/app-configuration-policies-overview",children:"https://learn.microsoft.com/en-us/mem/intune/apps/app-configuration-policies-overview"})}),"\n",(0,i.jsx)(n.li,{children:(0,i.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/apps/app-protection-policy",children:"https://learn.microsoft.com/en-us/mem/intune/apps/app-protection-policy"})}),"\n"]})]})}function l(e={}){const{wrapper:n}={...(0,o.R)(),...e.components};return n?(0,i.jsx)(n,{...e,children:(0,i.jsx)(d,{...e})}):d(e)}},28453:(e,n,t)=>{t.d(n,{R:()=>r,x:()=>a});var i=t(96540);const o={},s=i.createContext(o);function r(e){const n=i.useContext(s);return i.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function a(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(o):e.components||o:r(e.components),i.createElement(s.Provider,{value:n},e.children)}}}]);
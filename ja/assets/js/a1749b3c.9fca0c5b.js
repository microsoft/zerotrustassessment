"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[2439],{19458:(e,t,s)=>{s.r(t),s.d(t,{assets:()=>a,contentTitle:()=>c,default:()=>l,frontMatter:()=>o,metadata:()=>r,toc:()=>d});var n=s(74848),i=s(28453);const o={},c="042: Knox Attestation",r={id:"workshop-guidance/devices/RMD_042",title:"042: Knox Attestation",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_042.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_042",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_042",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_042.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"041: Require device lock",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_041"},next:{title:"043: Require SafetyNet",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_043"}},a={},d=[{value:"Overview",id:"overview",level:2},{value:"Reference",id:"reference",level:2}];function h(e){const t={a:"a",h1:"h1",h2:"h2",header:"header",li:"li",p:"p",strong:"strong",ul:"ul",...(0,i.R)(),...e.components};return(0,n.jsxs)(n.Fragment,{children:[(0,n.jsx)(t.header,{children:(0,n.jsx)(t.h1,{id:"042-knox-attestation",children:"042: Knox Attestation"})}),"\n",(0,n.jsx)(t.h2,{id:"overview",children:"Overview"}),"\n",(0,n.jsx)(t.p,{children:"Specify if the Samsung Knox device attestation check is required. Only unmodified devices that have been verified by Samsung can pass this check. For the list of supported devices, see samsungknox.com."}),"\n",(0,n.jsx)(t.p,{children:"By using this setting, Microsoft Intune will also verify communication from the Company Portal to the Intune Service was sent from a healthy device."}),"\n",(0,n.jsx)(t.p,{children:"Actions include:"}),"\n",(0,n.jsxs)(t.p,{children:[(0,n.jsx)(t.strong,{children:"Warn"})," - The user sees a notification if the device doesn't meet Samsung Knox device attestation check. This notification can be dismissed."]}),"\n",(0,n.jsxs)(t.p,{children:[(0,n.jsx)(t.strong,{children:"Block access"})," - The user account is blocked from access if the device doesn't meet Samsung's Knox device attestation check."]}),"\n",(0,n.jsxs)(t.p,{children:[(0,n.jsx)(t.strong,{children:"Wipe data"})," - The user account that is associated with the application is wiped from the device."]}),"\n",(0,n.jsxs)(t.p,{children:[(0,n.jsx)(t.strong,{children:"Note:"})," The user must accept the Samsung Knox terms before the device attestation check can be performed. If the user doesn't accept the Samsung Knox terms, the specified action will occur."]}),"\n",(0,n.jsxs)(t.p,{children:[(0,n.jsx)(t.strong,{children:"Note:"}),' This setting will apply to all devices targeted. To apply this setting only to Samsung devices, you can use "Managed apps" assignment filters.']}),"\n",(0,n.jsx)(t.h2,{id:"reference",children:"Reference"}),"\n",(0,n.jsxs)(t.ul,{children:["\n",(0,n.jsx)(t.li,{children:(0,n.jsx)(t.a,{href:"https://techcommunity.microsoft.com/t5/microsoft-intune-blog/hardware-backed-device-attestation-powers-mobile-workers/ba-p/3881209",children:"https://techcommunity.microsoft.com/t5/microsoft-intune-blog/hardware-backed-device-attestation-powers-mobile-workers/ba-p/3881209"})}),"\n",(0,n.jsx)(t.li,{children:(0,n.jsx)(t.a,{href:"https://learn.microsoft.com/en-us/mem/intune/apps/app-protection-policy-settings-android#device-conditions",children:"https://learn.microsoft.com/en-us/mem/intune/apps/app-protection-policy-settings-android#device-conditions"})}),"\n"]})]})}function l(e={}){const{wrapper:t}={...(0,i.R)(),...e.components};return t?(0,n.jsx)(t,{...e,children:(0,n.jsx)(h,{...e})}):h(e)}},28453:(e,t,s)=>{s.d(t,{R:()=>c,x:()=>r});var n=s(96540);const i={},o=n.createContext(i);function c(e){const t=n.useContext(o);return n.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function r(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:c(e.components),n.createElement(o.Provider,{value:t},e.children)}}}]);
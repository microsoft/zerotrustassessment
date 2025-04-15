"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[848],{62892:(e,t,o)=>{o.r(t),o.d(t,{assets:()=>l,contentTitle:()=>r,default:()=>u,frontMatter:()=>s,metadata:()=>a,toc:()=>d});var n=o(74848),i=o(28453);const s={},r="057: Rollout AutoPilot",a={id:"workshop-guidance/identity/RMI_057",title:"057: Rollout AutoPilot",description:"Overview",source:"@site/docs/workshop-guidance/identity/RMI_057.md",sourceDirName:"workshop-guidance/identity",slug:"/workshop-guidance/identity/RMI_057",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/identity/RMI_057",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/identity/RMI_057.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"056: Rollout Entra join for new workstations",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/identity/RMI_056"},next:{title:"058: Remove DJ Windows clients from Active Directory",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/identity/RMI_058"}},l={},d=[{value:"Overview",id:"overview",level:2},{value:"Reference",id:"reference",level:2}];function c(e){const t={a:"a",h1:"h1",h2:"h2",header:"header",li:"li",ol:"ol",p:"p",ul:"ul",...(0,i.R)(),...e.components};return(0,n.jsxs)(n.Fragment,{children:[(0,n.jsx)(t.header,{children:(0,n.jsx)(t.h1,{id:"057-rollout-autopilot",children:"057: Rollout AutoPilot"})}),"\n",(0,n.jsx)(t.h2,{id:"overview",children:"Overview"}),"\n",(0,n.jsx)(t.p,{children:"Use Autopilot for device provisioning. There are two types of devices that should be configured for Autopilot:"}),"\n",(0,n.jsxs)(t.ol,{children:["\n",(0,n.jsx)(t.li,{children:"New devices shipped by your workstation vendors"}),"\n",(0,n.jsx)(t.li,{children:"Existing workstations already in the organization's possession"}),"\n"]}),"\n",(0,n.jsx)(t.p,{children:"It is recommended that you work with your workstation vendors to begin shipping new devices fully enabled for Autopilot and Entra cloud join."}),"\n",(0,n.jsx)(t.p,{children:"It is also recommended that you register your existing workstations for Autopilot by using scripts or tools like SCCM to capture hardware hash information. Then if any of those devices require imaging in the future they can be imaged in such a way that they follow the Autopilot plus Entra Join pattern that new devices leverage. This will help speed the transition to Autopilot and Entra Joined PCs."}),"\n",(0,n.jsx)(t.h2,{id:"reference",children:"Reference"}),"\n",(0,n.jsxs)(t.ul,{children:["\n",(0,n.jsx)(t.li,{children:(0,n.jsx)(t.a,{href:"https://learn.microsoft.com/en-us/autopilot/windows-autopilot",children:"Overview of Windows Autopilot | Microsoft Learn"})}),"\n"]})]})}function u(e={}){const{wrapper:t}={...(0,i.R)(),...e.components};return t?(0,n.jsx)(t,{...e,children:(0,n.jsx)(c,{...e})}):c(e)}},28453:(e,t,o)=>{o.d(t,{R:()=>r,x:()=>a});var n=o(96540);const i={},s=n.createContext(i);function r(e){const t=n.useContext(s);return n.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function a(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:r(e.components),n.createElement(s.Provider,{value:t},e.children)}}}]);
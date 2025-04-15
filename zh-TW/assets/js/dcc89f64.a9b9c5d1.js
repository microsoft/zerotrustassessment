"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[7406],{48765:(e,s,t)=>{t.r(s),t.d(s,{assets:()=>a,contentTitle:()=>o,default:()=>l,frontMatter:()=>r,metadata:()=>c,toc:()=>p});var n=t(74848),i=t(28453);const r={},o="010: Multi-Admin Approval",c={id:"workshop-guidance/devices/RMD_010",title:"010: Multi-Admin Approval",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_010.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_010",permalink:"/zerotrustassessment/zh-TW/docs/workshop-guidance/devices/RMD_010",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_010.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"009: Graph API",permalink:"/zerotrustassessment/zh-TW/docs/workshop-guidance/devices/RMD_009"},next:{title:"011: Offboarding Strategy",permalink:"/zerotrustassessment/zh-TW/docs/workshop-guidance/devices/RMD_011"}},a={},p=[{value:"Overview",id:"overview",level:2},{value:"Reference",id:"reference",level:2}];function d(e){const s={a:"a",h1:"h1",h2:"h2",header:"header",li:"li",p:"p",ul:"ul",...(0,i.R)(),...e.components};return(0,n.jsxs)(n.Fragment,{children:[(0,n.jsx)(s.header,{children:(0,n.jsx)(s.h1,{id:"010-multi-admin-approval",children:"010: Multi-Admin Approval"})}),"\n",(0,n.jsx)(s.h2,{id:"overview",children:"Overview"}),"\n",(0,n.jsx)(s.p,{children:"To help protect against a compromised administrative account, use Intune access policies to require that a second administrative account is used to approve a change before the change is applied. This capability is known as multiple administrative approval (MAA)."}),"\n",(0,n.jsx)(s.p,{children:"With MAA, you configure access policies that protect specific configurations, like Apps or Scripts for devices. Access policies specify what is protected and which group of accounts are permitted to approve changes to those resources."}),"\n",(0,n.jsx)(s.p,{children:"When any account in the Tenant is used to make a change to a resource that\u2019s protected by an access policy, Intune won't apply the change until a different account explicitly approves it. Only administrators who are members of an approval group that\u2019s assigned a protected resource in an access protection policy can approve changes. Approvers can also reject change requests."}),"\n",(0,n.jsx)(s.p,{children:"Access policies are supported for the following resources:"}),"\n",(0,n.jsxs)(s.ul,{children:["\n",(0,n.jsx)(s.li,{children:"Apps \u2013 Applies to app deployments, but doesn't apply to app protection policies."}),"\n",(0,n.jsx)(s.li,{children:"Scripts \u2013 Applies to deploying scripts to devices that run Windows."}),"\n"]}),"\n",(0,n.jsx)(s.h2,{id:"reference",children:"Reference"}),"\n",(0,n.jsxs)(s.ul,{children:["\n",(0,n.jsx)(s.li,{children:(0,n.jsx)(s.a,{href:"https://learn.microsoft.com/en-us/mem/intune/fundamentals/multi-admin-approval",children:"https://learn.microsoft.com/en-us/mem/intune/fundamentals/multi-admin-approval"})}),"\n"]})]})}function l(e={}){const{wrapper:s}={...(0,i.R)(),...e.components};return s?(0,n.jsx)(s,{...e,children:(0,n.jsx)(d,{...e})}):d(e)}},28453:(e,s,t)=>{t.d(s,{R:()=>o,x:()=>c});var n=t(96540);const i={},r=n.createContext(i);function o(e){const s=n.useContext(r);return n.useMemo((function(){return"function"==typeof e?e(s):{...s,...e}}),[s,e])}function c(e){let s;return s=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:o(e.components),n.createElement(r.Provider,{value:s},e.children)}}}]);
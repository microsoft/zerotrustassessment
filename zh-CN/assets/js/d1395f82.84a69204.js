"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[4745],{64059:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>d,contentTitle:()=>s,default:()=>u,frontMatter:()=>o,metadata:()=>a,toc:()=>c});var i=n(74848),r=n(28453);const o={},s="070: Rollout strong auth credentials for Workload Identities",a={id:"workshop-guidance/identity/RMI_070",title:"070: Rollout strong auth credentials for Workload Identities",description:"Overview",source:"@site/docs/workshop-guidance/identity/RMI_070.md",sourceDirName:"workshop-guidance/identity",slug:"/workshop-guidance/identity/RMI_070",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/identity/RMI_070",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/identity/RMI_070.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"069: Discover & analyze privileged usage for Workfload Identities (eg scripts)",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/identity/RMI_069"},next:{title:"071: Rollout Conditional Access for Workload Identities",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/identity/RMI_071"}},d={},c=[{value:"Overview",id:"overview",level:2},{value:"Reference",id:"reference",level:2}];function l(e){const t={a:"a",h1:"h1",h2:"h2",header:"header",li:"li",p:"p",ul:"ul",...(0,r.R)(),...e.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(t.header,{children:(0,i.jsx)(t.h1,{id:"070-rollout-strong-auth-credentials-for-workload-identities",children:"070: Rollout strong auth credentials for Workload Identities"})}),"\n",(0,i.jsx)(t.h2,{id:"overview",children:"Overview"}),"\n",(0,i.jsx)(t.p,{children:"Use Azure Managed Identities and certificates for cloud workload identities. Organizations should establish a pattern where workload identities and automation credentials use one of the options below:"}),"\n",(0,i.jsxs)(t.ul,{children:["\n",(0,i.jsx)(t.li,{children:"Managed identity"}),"\n",(0,i.jsx)(t.li,{children:"Certificate"}),"\n",(0,i.jsx)(t.li,{children:"Federated workload identity"}),"\n"]}),"\n",(0,i.jsx)(t.p,{children:"Customers should avoid using the weakest option:"}),"\n",(0,i.jsxs)(t.ul,{children:["\n",(0,i.jsx)(t.li,{children:"Client secret"}),"\n"]}),"\n",(0,i.jsx)(t.p,{children:"Usage of client secrets should require an exception, since it should violate normal security requirements."}),"\n",(0,i.jsx)(t.h2,{id:"reference",children:"Reference"}),"\n",(0,i.jsxs)(t.ul,{children:["\n",(0,i.jsx)(t.li,{children:(0,i.jsx)(t.a,{href:"https://learn.microsoft.com/en-us/azure/deployment-environments/how-to-configure-managed-identity",children:"Configure a managed identity for Azure Deployment Environments - Azure Deployment Environments | Microsoft Learn"})}),"\n",(0,i.jsx)(t.li,{children:(0,i.jsx)(t.a,{href:"https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-service-principal-portal#option-1-recommended-upload-a-trusted-certificate-issued-by-a-certificate-authority",children:"Create a Microsoft Entra app and service principal in the portal - Microsoft identity platform | Microsoft Learn"})}),"\n"]})]})}function u(e={}){const{wrapper:t}={...(0,r.R)(),...e.components};return t?(0,i.jsx)(t,{...e,children:(0,i.jsx)(l,{...e})}):l(e)}},28453:(e,t,n)=>{n.d(t,{R:()=>s,x:()=>a});var i=n(96540);const r={},o=i.createContext(r);function s(e){const t=i.useContext(o);return i.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function a(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(r):e.components||r:s(e.components),i.createElement(o.Provider,{value:t},e.children)}}}]);
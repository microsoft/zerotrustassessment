"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[360],{89776:(e,n,i)=>{i.r(n),i.d(n,{assets:()=>d,contentTitle:()=>o,default:()=>u,frontMatter:()=>t,metadata:()=>c,toc:()=>a});var s=i(74848),r=i(28453);const t={},o="116: Deploy Hybrid Entra Join",c={id:"workshop-guidance/devices/RMD_116",title:"116: Deploy Hybrid Entra Join",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_116.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_116",permalink:"/zerotrustassessment/ko/docs/workshop-guidance/devices/RMD_116",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_116.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"115: Co-management Strategy",permalink:"/zerotrustassessment/ko/docs/workshop-guidance/devices/RMD_115"},next:{title:"117: Deploy Entra Join Only",permalink:"/zerotrustassessment/ko/docs/workshop-guidance/devices/RMD_117"}},d={},a=[{value:"Overview",id:"overview",level:2},{value:"Reference",id:"reference",level:2}];function l(e){const n={a:"a",h1:"h1",h2:"h2",header:"header",li:"li",p:"p",strong:"strong",ul:"ul",...(0,r.R)(),...e.components};return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)(n.header,{children:(0,s.jsx)(n.h1,{id:"116-deploy-hybrid-entra-join",children:"116: Deploy Hybrid Entra Join"})}),"\n",(0,s.jsx)(n.h2,{id:"overview",children:"Overview"}),"\n",(0,s.jsxs)(n.p,{children:[(0,s.jsx)(n.strong,{children:"Hybrid Microsoft Entra joined"}),": Devices are registered in Microsoft Entra and joined to an on-premises AD domain. You should plan to hybrid join your existing endpoints that are joined to an on-premises AD domain."]}),"\n",(0,s.jsx)(n.p,{children:"Hybrid Microsoft Entra joined devices get a cloud identity and can use cloud services that require a cloud identity. For end users with existing endpoints, this option has minimal impact."}),"\n",(0,s.jsx)(n.p,{children:"These devices require a network line-of-sight to your on-premises domain controllers (DCs) for initial sign-in and for device management. If the devices can't connect to the DC, then users might be prevented from signing in, and may not receive policy updates."}),"\n",(0,s.jsx)(n.p,{children:"Scenarios that break without line of sight to your domain controllers include:"}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsx)(n.li,{children:"Group policy updates from AD"}),"\n",(0,s.jsx)(n.li,{children:"Device password change"}),"\n",(0,s.jsx)(n.li,{children:"User password change (Cached credentials)"}),"\n",(0,s.jsx)(n.li,{children:"Trusted Platform Module (TPM) reset"}),"\n"]}),"\n",(0,s.jsx)(n.h2,{id:"reference",children:"Reference"}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsx)(n.li,{children:(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/entra/identity/devices/plan-device-deployment",children:"Plan your Microsoft Entra device deployment"})}),"\n",(0,s.jsx)(n.li,{children:(0,s.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/windows/client-management/enroll-a-windows-10-device-automatically-using-group-policy",children:"Enroll a Windows device automatically using Group Policy"})}),"\n"]})]})}function u(e={}){const{wrapper:n}={...(0,r.R)(),...e.components};return n?(0,s.jsx)(n,{...e,children:(0,s.jsx)(l,{...e})}):l(e)}},28453:(e,n,i)=>{i.d(n,{R:()=>o,x:()=>c});var s=i(96540);const r={},t=s.createContext(r);function o(e){const n=s.useContext(t);return s.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function c(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(r):e.components||r:o(e.components),s.createElement(t.Provider,{value:n},e.children)}}}]);
"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[8475],{95157:(e,s,t)=>{t.r(s),t.d(s,{assets:()=>l,contentTitle:()=>i,default:()=>u,frontMatter:()=>r,metadata:()=>o,toc:()=>c});var n=t(74848),a=t(28453);const r={},i="008: Manually classify sensitive assets",o={id:"workshop-guidance/data/RMT_008",title:"008: Manually classify sensitive assets",description:"Overview",source:"@site/docs/workshop-guidance/data/RMT_008.md",sourceDirName:"workshop-guidance/data",slug:"/workshop-guidance/data/RMT_008",permalink:"/zerotrustassessment/zh-TW/docs/workshop-guidance/data/RMT_008",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/data/RMT_008.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"007: Identify Automatic Classification cases",permalink:"/zerotrustassessment/zh-TW/docs/workshop-guidance/data/RMT_007"},next:{title:"009: Implement label recommendations",permalink:"/zerotrustassessment/zh-TW/docs/workshop-guidance/data/RMT_009"}},l={},c=[{value:"Overview",id:"overview",level:2},{value:"Reference",id:"reference",level:2}];function d(e){const s={a:"a",h1:"h1",h2:"h2",header:"header",li:"li",p:"p",ul:"ul",...(0,a.R)(),...e.components};return(0,n.jsxs)(n.Fragment,{children:[(0,n.jsx)(s.header,{children:(0,n.jsx)(s.h1,{id:"008-manually-classify-sensitive-assets",children:"008: Manually classify sensitive assets"})}),"\n",(0,n.jsx)(s.h2,{id:"overview",children:"Overview"}),"\n",(0,n.jsx)(s.p,{children:"Train and evaluate users for manually applying sensitivity labels. Start with a group of pilot users who are trained to use labels, and after a period of a few weeks identify (using Content Explorer) files which they have labeled manually, as well as known files you would expect to have been labeled, and compare the results with the expected label for each asset as evaluated by the security team.\nWhen implementing labels, you should initially deploy them without usage restrictions, watermarks and other controls in order to assess users behavior without consideration of the impact of such restrictions."}),"\n",(0,n.jsx)(s.p,{children:"This step precedes using recommended and automatic labeling mechanisms that don't rely on the end user making a decision to apply a label."}),"\n",(0,n.jsx)(s.h2,{id:"reference",children:"Reference"}),"\n",(0,n.jsxs)(s.ul,{children:["\n",(0,n.jsxs)(s.li,{children:["Create and publish sensitivity labels ",(0,n.jsx)(s.a,{href:"https://learn.microsoft.com/en-us/purview/create-sensitivity-labels",children:"https://learn.microsoft.com/en-us/purview/create-sensitivity-labels"})]}),"\n",(0,n.jsxs)(s.li,{children:["Content Explorer: ",(0,n.jsx)(s.a,{href:"https://learn.microsoft.com/en-us/purview/data-classification-content-explorer",children:"https://learn.microsoft.com/en-us/purview/data-classification-content-explorer"}),"\xa0"]}),"\n",(0,n.jsxs)(s.li,{children:["Content Explorer PowerShell: ",(0,n.jsx)(s.a,{href:"https://learn.microsoft.com/en-us/powershell/module/exchange/export-contentexplorerdata",children:"https://learn.microsoft.com/en-us/powershell/module/exchange/export-contentexplorerdata"}),"\xa0 \xa0 \xa0"]}),"\n",(0,n.jsxs)(s.li,{children:["Activity Explorer: ",(0,n.jsx)(s.a,{href:"https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer",children:"https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer"})]}),"\n"]})]})}function u(e={}){const{wrapper:s}={...(0,a.R)(),...e.components};return s?(0,n.jsx)(s,{...e,children:(0,n.jsx)(d,{...e})}):d(e)}},28453:(e,s,t)=>{t.d(s,{R:()=>i,x:()=>o});var n=t(96540);const a={},r=n.createContext(a);function i(e){const s=n.useContext(r);return n.useMemo((function(){return"function"==typeof e?e(s):{...s,...e}}),[s,e])}function o(e){let s;return s=e.disableParentContext?"function"==typeof e.components?e.components(a):e.components||a:i(e.components),n.createElement(r.Provider,{value:s},e.children)}}}]);
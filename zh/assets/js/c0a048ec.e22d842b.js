"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[513],{72327:(e,s,n)=>{n.r(s),n.d(s,{assets:()=>c,contentTitle:()=>r,default:()=>l,frontMatter:()=>o,metadata:()=>a,toc:()=>d});var t=n(74848),i=n(28453);const o={},r="011: Monitor sharing with customers",a={id:"workshop-guidance/data/RMT_011",title:"011: Monitor sharing with customers",description:"Overview",source:"@site/docs/workshop-guidance/data/RMT_011.md",sourceDirName:"workshop-guidance/data",slug:"/workshop-guidance/data/RMT_011",permalink:"/zerotrustassessment/zh/docs/workshop-guidance/data/RMT_011",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/data/RMT_011.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"010: Monitor external sharing",permalink:"/zerotrustassessment/zh/docs/workshop-guidance/data/RMT_010"},next:{title:"012: Deploy Data Loss Prevention policies",permalink:"/zerotrustassessment/zh/docs/workshop-guidance/data/RMT_012"}},c={},d=[{value:"Overview",id:"overview",level:2},{value:"Reference",id:"reference",level:2}];function h(e){const s={a:"a",h1:"h1",h2:"h2",header:"header",li:"li",p:"p",ul:"ul",...(0,i.R)(),...e.components};return(0,t.jsxs)(t.Fragment,{children:[(0,t.jsx)(s.header,{children:(0,t.jsx)(s.h1,{id:"011-monitor-sharing-with-customers",children:"011: Monitor sharing with customers"})}),"\n",(0,t.jsx)(s.h2,{id:"overview",children:"Overview"}),"\n",(0,t.jsx)(s.p,{children:"Based on the scenarios of sharing data with customers (external users), design the DLP policies to block external sharing scenarios not matching these patterns. Use both sensitive information types as conditions and sensitivity labels as conditions and DLP rule exceptions to address those scenarios. Select different combinations of evidence with varying levels of certainty to implement controls at different levels of assertiveness. For example:\nSingle match and low or medium confidence matches: warn the user.\nSingle match and high confidence matches: block with override.\nMultiple matches with low or medium confidence: block with override.\nMultiple matches with high confidence: block.\nLarge number of matches with medium confidence: block."}),"\n",(0,t.jsx)(s.p,{children:"Configure these policies across different sharing scenarios, including SharePoint, OneDrive, Teams, Endpoint and Exchange.\nUse Exact Data Matching as a high confidence classifier. Use regular SITs with validators and keywords as medium or high confidence classifiers. Use regular SITs with no keywords as low confidence matches. You can also use trainable classifiers together with regular SITs as conditions representing high confidence situations."}),"\n",(0,t.jsx)(s.p,{children:"Do not deploy the DLP rules at this stage, configure them but keep them in simulation mode in order to assess potential impact, and after a few weeks assess if critical business scenarios could have been impacted by these rules if they had been enforced. Adjust the logic of the rules and their enforcement actions (e.g. usage of policy tips, overrides and exceptions) as needed."}),"\n",(0,t.jsx)(s.h2,{id:"reference",children:"Reference"}),"\n",(0,t.jsxs)(s.ul,{children:["\n",(0,t.jsxs)(s.li,{children:["Create and Deploy data loss prevention policies ",(0,t.jsx)(s.a,{href:"https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy",children:"https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy"})]}),"\n"]})]})}function l(e={}){const{wrapper:s}={...(0,i.R)(),...e.components};return s?(0,t.jsx)(s,{...e,children:(0,t.jsx)(h,{...e})}):h(e)}},28453:(e,s,n)=>{n.d(s,{R:()=>r,x:()=>a});var t=n(96540);const i={},o=t.createContext(i);function r(e){const s=t.useContext(o);return t.useMemo((function(){return"function"==typeof e?e(s):{...s,...e}}),[s,e])}function a(e){let s;return s=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:r(e.components),t.createElement(o.Provider,{value:s},e.children)}}}]);
"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[6466],{72451:(e,t,s)=>{s.r(t),s.d(t,{assets:()=>l,contentTitle:()=>c,default:()=>d,frontMatter:()=>o,metadata:()=>i,toc:()=>a});var n=s(74848),r=s(28453);s(5871);const o={},c="Frequently Asked Questions (FAQs)",i={id:"zFAQs/index",title:"Frequently Asked Questions (FAQs)",description:"- General FAQs",source:"@site/docs/zFAQs/index.mdx",sourceDirName:"zFAQs",slug:"/zFAQs/",permalink:"/zerotrustassessment/zh-TW/docs/zFAQs/",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/zFAQs/index.mdx",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"Zero Trust Assessment",permalink:"/zerotrustassessment/zh-TW/docs/videos/Assessment"},next:{title:"General FAQs",permalink:"/zerotrustassessment/zh-TW/docs/zFAQs/generalFAQs"}},l={},a=[];function u(e){const t={a:"a",h1:"h1",header:"header",li:"li",p:"p",ul:"ul",...(0,r.R)(),...e.components};return(0,n.jsxs)(n.Fragment,{children:[(0,n.jsx)(t.header,{children:(0,n.jsx)(t.h1,{id:"frequently-asked-questions-faqs",children:"Frequently Asked Questions (FAQs)"})}),"\n",(0,n.jsxs)(t.ul,{children:["\n",(0,n.jsxs)(t.li,{children:["\n",(0,n.jsx)(t.p,{children:(0,n.jsx)(t.a,{href:"./zFAQs/generalFAQs",children:"General FAQs"})}),"\n"]}),"\n",(0,n.jsxs)(t.li,{children:["\n",(0,n.jsx)(t.p,{children:(0,n.jsx)(t.a,{href:"./zFAQs/partnerFAQs",children:"Microsoft Partner FAQs"})}),"\n"]}),"\n"]})]})}function d(e={}){const{wrapper:t}={...(0,r.R)(),...e.components};return t?(0,n.jsx)(t,{...e,children:(0,n.jsx)(u,{...e})}):u(e)}},5871:(e,t,s)=>{s.d(t,{A:()=>k});var n=s(96540),r=s(34164),o=s(44718),c=s(28774),i=s(44586);const l=["zero","one","two","few","many","other"];function a(e){return l.filter((t=>e.includes(t)))}const u={locale:"en",pluralForms:a(["one","other"]),select:e=>1===e?"one":"other"};function d(){const{i18n:{currentLocale:e}}=(0,i.A)();return(0,n.useMemo)((()=>{try{return function(e){const t=new Intl.PluralRules(e);return{locale:e,pluralForms:a(t.resolvedOptions().pluralCategories),select:e=>t.select(e)}}(e)}catch(t){return console.error(`Failed to use Intl.PluralRules for locale "${e}".\nDocusaurus will fallback to the default (English) implementation.\nError: ${t.message}\n`),u}}),[e])}function m(){const e=d();return{selectMessage:(t,s)=>function(e,t,s){const n=e.split("|");if(1===n.length)return n[0];n.length>s.pluralForms.length&&console.error(`For locale=${s.locale}, a maximum of ${s.pluralForms.length} plural forms are expected (${s.pluralForms.join(",")}), but the message contains ${n.length}: ${e}`);const r=s.select(t),o=s.pluralForms.indexOf(r);return n[Math.min(o,n.length-1)]}(s,t,e)}}var h=s(16654),f=s(21312),p=s(51107);const x={cardContainer:"cardContainer_fWXF",cardTitle:"cardTitle_rnsV",cardDescription:"cardDescription_PWke"};var A=s(74848);function F(e){let{href:t,children:s}=e;return(0,A.jsx)(c.A,{href:t,className:(0,r.A)("card padding--lg",x.cardContainer),children:s})}function g(e){let{href:t,icon:s,title:n,description:o}=e;return(0,A.jsxs)(F,{href:t,children:[(0,A.jsxs)(p.A,{as:"h2",className:(0,r.A)("text--truncate",x.cardTitle),title:n,children:[s," ",n]}),o&&(0,A.jsx)("p",{className:(0,r.A)("text--truncate",x.cardDescription),title:o,children:o})]})}function j(e){let{item:t}=e;const s=(0,o.Nr)(t),n=function(){const{selectMessage:e}=m();return t=>e(t,(0,f.T)({message:"1 item|{count} items",id:"theme.docs.DocCard.categoryDescription.plurals",description:"The default description for a category card in the generated index about how many items this category includes"},{count:t}))}();return s?(0,A.jsx)(g,{href:s,icon:"\ud83d\uddc3\ufe0f",title:t.label,description:t.description??n(t.items.length)}):null}function Q(e){let{item:t}=e;const s=(0,h.A)(t.href)?"\ud83d\udcc4\ufe0f":"\ud83d\udd17",n=(0,o.cC)(t.docId??void 0);return(0,A.jsx)(g,{href:t.href,icon:s,title:t.label,description:t.description??n?.description})}function z(e){let{item:t}=e;switch(t.type){case"link":return(0,A.jsx)(Q,{item:t});case"category":return(0,A.jsx)(j,{item:t});default:throw new Error(`unknown item type ${JSON.stringify(t)}`)}}function y(e){let{className:t}=e;const s=(0,o.$S)();return(0,A.jsx)(k,{items:s.items,className:t})}function k(e){const{items:t,className:s}=e;if(!t)return(0,A.jsx)(y,{...e});const n=(0,o.d1)(t);return(0,A.jsx)("section",{className:(0,r.A)("row",s),children:n.map(((e,t)=>(0,A.jsx)("article",{className:"col col--6 margin-bottom--lg",children:(0,A.jsx)(z,{item:e})},t)))})}},28453:(e,t,s)=>{s.d(t,{R:()=>c,x:()=>i});var n=s(96540);const r={},o=n.createContext(r);function c(e){const t=n.useContext(o);return n.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function i(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(r):e.components||r:c(e.components),n.createElement(o.Provider,{value:t},e.children)}}}]);
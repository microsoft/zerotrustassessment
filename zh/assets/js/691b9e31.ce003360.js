"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[5791],{4578:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>l,contentTitle:()=>i,default:()=>u,frontMatter:()=>o,metadata:()=>c,toc:()=>a});var r=n(74848),s=n(28453);n(5871);const o={},i="Workshop Guided Videos",c={id:"videos/index",title:"Workshop Guided Videos",description:"Video Index",source:"@site/docs/videos/index.mdx",sourceDirName:"videos",slug:"/videos/",permalink:"/zerotrustassessment/zh/docs/videos/",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/videos/index.mdx",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"026: Evaluate and implement special cryptographic needs (BYOK, DKE)",permalink:"/zerotrustassessment/zh/docs/workshop-guidance/data/RMT_026"},next:{title:"Introduction to the Zero Trust Workshop",permalink:"/zerotrustassessment/zh/docs/videos/IntroductionToZT"}},l={},a=[{value:"Video Index",id:"video-index",level:2}];function d(e){const t={a:"a",h1:"h1",h2:"h2",header:"header",li:"li",p:"p",ul:"ul",...(0,s.R)(),...e.components};return(0,r.jsxs)(r.Fragment,{children:[(0,r.jsx)(t.header,{children:(0,r.jsx)(t.h1,{id:"workshop-guided-videos",children:"Workshop Guided Videos"})}),"\n",(0,r.jsx)(t.h2,{id:"video-index",children:"Video Index"}),"\n",(0,r.jsx)(t.p,{children:"We have produced the following videos to help you run your own workshops:"}),"\n",(0,r.jsxs)(t.ul,{children:["\n",(0,r.jsxs)(t.li,{children:["\n",(0,r.jsx)(t.p,{children:(0,r.jsx)(t.a,{href:"./videos/IntroductionToZT",children:"Introduction to the Zero Trust Workshop"})}),"\n"]}),"\n",(0,r.jsxs)(t.li,{children:["\n",(0,r.jsx)(t.p,{children:(0,r.jsx)(t.a,{href:"./videos/IdentityPillar",children:"Identity Pillar"})}),"\n"]}),"\n",(0,r.jsxs)(t.li,{children:["\n",(0,r.jsx)(t.p,{children:(0,r.jsx)(t.a,{href:"./videos/DevicesPillar",children:"Devices Pillar"})}),"\n"]}),"\n",(0,r.jsxs)(t.li,{children:["\n",(0,r.jsx)(t.p,{children:(0,r.jsx)(t.a,{href:"./videos/DataPillar",children:"Data Pillar"})}),"\n"]}),"\n",(0,r.jsxs)(t.li,{children:["\n",(0,r.jsx)(t.p,{children:(0,r.jsx)(t.a,{href:"./videos/Assessment",children:"Zero Trust Assessment Overview"})}),"\n"]}),"\n"]})]})}function u(e={}){const{wrapper:t}={...(0,s.R)(),...e.components};return t?(0,r.jsx)(t,{...e,children:(0,r.jsx)(d,{...e})}):d(e)}},5871:(e,t,n)=>{n.d(t,{A:()=>b});var r=n(96540),s=n(34164),o=n(44718),i=n(28774),c=n(44586);const l=["zero","one","two","few","many","other"];function a(e){return l.filter((t=>e.includes(t)))}const d={locale:"en",pluralForms:a(["one","other"]),select:e=>1===e?"one":"other"};function u(){const{i18n:{currentLocale:e}}=(0,c.A)();return(0,r.useMemo)((()=>{try{return function(e){const t=new Intl.PluralRules(e);return{locale:e,pluralForms:a(t.resolvedOptions().pluralCategories),select:e=>t.select(e)}}(e)}catch(t){return console.error(`Failed to use Intl.PluralRules for locale "${e}".\nDocusaurus will fallback to the default (English) implementation.\nError: ${t.message}\n`),d}}),[e])}function h(){const e=u();return{selectMessage:(t,n)=>function(e,t,n){const r=e.split("|");if(1===r.length)return r[0];r.length>n.pluralForms.length&&console.error(`For locale=${n.locale}, a maximum of ${n.pluralForms.length} plural forms are expected (${n.pluralForms.join(",")}), but the message contains ${r.length}: ${e}`);const s=n.select(t),o=n.pluralForms.indexOf(s);return r[Math.min(o,r.length-1)]}(n,t,e)}}var m=n(16654),p=n(21312),f=n(51107);const x={cardContainer:"cardContainer_fWXF",cardTitle:"cardTitle_rnsV",cardDescription:"cardDescription_PWke"};var j=n(74848);function v(e){let{href:t,children:n}=e;return(0,j.jsx)(i.A,{href:t,className:(0,s.A)("card padding--lg",x.cardContainer),children:n})}function g(e){let{href:t,icon:n,title:r,description:o}=e;return(0,j.jsxs)(v,{href:t,children:[(0,j.jsxs)(f.A,{as:"h2",className:(0,s.A)("text--truncate",x.cardTitle),title:r,children:[n," ",r]}),o&&(0,j.jsx)("p",{className:(0,s.A)("text--truncate",x.cardDescription),title:o,children:o})]})}function k(e){let{item:t}=e;const n=(0,o.Nr)(t),r=function(){const{selectMessage:e}=h();return t=>e(t,(0,p.T)({message:"1 item|{count} items",id:"theme.docs.DocCard.categoryDescription.plurals",description:"The default description for a category card in the generated index about how many items this category includes"},{count:t}))}();return n?(0,j.jsx)(g,{href:n,icon:"\ud83d\uddc3\ufe0f",title:t.label,description:t.description??r(t.items.length)}):null}function w(e){let{item:t}=e;const n=(0,m.A)(t.href)?"\ud83d\udcc4\ufe0f":"\ud83d\udd17",r=(0,o.cC)(t.docId??void 0);return(0,j.jsx)(g,{href:t.href,icon:n,title:t.label,description:t.description??r?.description})}function y(e){let{item:t}=e;switch(t.type){case"link":return(0,j.jsx)(w,{item:t});case"category":return(0,j.jsx)(k,{item:t});default:throw new Error(`unknown item type ${JSON.stringify(t)}`)}}function T(e){let{className:t}=e;const n=(0,o.$S)();return(0,j.jsx)(b,{items:n.items,className:t})}function b(e){const{items:t,className:n}=e;if(!t)return(0,j.jsx)(T,{...e});const r=(0,o.d1)(t);return(0,j.jsx)("section",{className:(0,s.A)("row",n),children:r.map(((e,t)=>(0,j.jsx)("article",{className:"col col--6 margin-bottom--lg",children:(0,j.jsx)(y,{item:e})},t)))})}},28453:(e,t,n)=>{n.d(t,{R:()=>i,x:()=>c});var r=n(96540);const s={},o=r.createContext(s);function i(e){const t=r.useContext(o);return r.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function c(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(s):e.components||s:i(e.components),r.createElement(o.Provider,{value:t},e.children)}}}]);
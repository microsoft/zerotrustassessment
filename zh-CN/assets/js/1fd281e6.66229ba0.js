"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[8920],{27743:(e,n,s)=>{s.r(n),s.d(n,{assets:()=>c,contentTitle:()=>o,default:()=>h,frontMatter:()=>t,metadata:()=>l,toc:()=>d});var r=s(74848),i=s(28453);const t={},o="070: User enrollment",l={id:"workshop-guidance/devices/RMD_070",title:"070: User enrollment",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_070.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_070",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/devices/RMD_070",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_070.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"069: Webapp Deployment",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/devices/RMD_069"},next:{title:"071: ABM Provisioning",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/devices/RMD_071"}},c={},d=[{value:"Overview",id:"overview",level:2},{value:"Reference",id:"reference",level:2}];function a(e){const n={a:"a",h1:"h1",h2:"h2",header:"header",li:"li",ol:"ol",p:"p",strong:"strong",ul:"ul",...(0,i.R)(),...e.components};return(0,r.jsxs)(r.Fragment,{children:[(0,r.jsx)(n.header,{children:(0,r.jsx)(n.h1,{id:"070-user-enrollment",children:"070: User enrollment"})}),"\n",(0,r.jsx)(n.h2,{id:"overview",children:"Overview"}),"\n",(0,r.jsxs)(n.ol,{children:["\n",(0,r.jsxs)(n.li,{children:["\n",(0,r.jsxs)(n.p,{children:[(0,r.jsx)(n.strong,{children:"Overview"}),":"]}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Apple User Enrollment"})," is designed for securely using personally owned devices (BYOD) for work apps without giving up management of the entire device to organizations."]}),"\n",(0,r.jsx)(n.li,{children:"It sets up the personal device so that work data is stored separately from personal data and apps."}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Supervised mode"})," isn't available with this enrollment type."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Supported methods"}),":","\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Account-driven user enrollment"}),": The device user initiates enrollment by adding their work or school account in the Settings app. Intune policies are applied silently."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"User enrollment with Company Portal"}),": The user signs into the Intune Company Portal app, downloads a preconfigured enrollment profile, and installs it via the Settings app."]}),"\n"]}),"\n"]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Privacy"}),": Organizations can apply necessary configurations and policies (e.g., passcode requirements, mandatory apps) without controlling the camera or accessing personal information\xb2."]}),"\n"]}),"\n"]}),"\n",(0,r.jsxs)(n.li,{children:["\n",(0,r.jsxs)(n.p,{children:[(0,r.jsx)(n.strong,{children:"Benefits"}),":"]}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Privacy"}),": Separates work data from personal data, respecting user privacy."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"User-friendly"}),": Simple enrollment process for users."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Limited management"}),": Admins have a restricted set of policies and configurations."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"BYOD support"}),": Ideal for personal devices."]}),"\n"]}),"\n"]}),"\n",(0,r.jsxs)(n.li,{children:["\n",(0,r.jsxs)(n.p,{children:[(0,r.jsx)(n.strong,{children:"Drawbacks"}),":"]}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Limited control"}),": Admins cannot fully manage the entire device."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"No supervision"}),": No supervised mode for additional control."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Restricted settings"}),": Only settings supported by Apple User Enrollment take effect."]}),"\n"]}),"\n"]}),"\n",(0,r.jsxs)(n.li,{children:["\n",(0,r.jsxs)(n.p,{children:[(0,r.jsx)(n.strong,{children:"Impact"}),":"]}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Positive"}),": Easy enrollment, privacy protection."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Negative"}),": Limited device management."]}),"\n"]}),"\n"]}),"\n",(0,r.jsxs)(n.li,{children:["\n",(0,r.jsxs)(n.p,{children:[(0,r.jsx)(n.strong,{children:"Comparison to ABM Enrollment"}),":"]}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Apple Business Manager (ABM)"}),": For corporate-owned devices.","\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Supervised mode"}),": Provides more control."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Full management"}),": Admins can manage the entire device."]}),"\n",(0,r.jsxs)(n.li,{children:[(0,r.jsx)(n.strong,{children:"Ideal for corporate devices"}),"."]}),"\n"]}),"\n"]}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,r.jsx)(n.p,{children:"In summary, Apple User Enrollment balances privacy and management, making it suitable for BYOD scenarios, while ABM offers more control for corporate devices."}),"\n",(0,r.jsx)(n.h2,{id:"reference",children:"Reference"}),"\n",(0,r.jsxs)(n.ul,{children:["\n",(0,r.jsx)(n.li,{children:(0,r.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/enrollment/ios-user-enrollment-supported-actions",children:"https://learn.microsoft.com/en-us/mem/intune/enrollment/ios-user-enrollment-supported-actions"})}),"\n"]})]})}function h(e={}){const{wrapper:n}={...(0,i.R)(),...e.components};return n?(0,r.jsx)(n,{...e,children:(0,r.jsx)(a,{...e})}):a(e)}},28453:(e,n,s)=>{s.d(n,{R:()=>o,x:()=>l});var r=s(96540);const i={},t=r.createContext(i);function o(e){const n=r.useContext(t);return r.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function l(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:o(e.components),r.createElement(t.Provider,{value:n},e.children)}}}]);
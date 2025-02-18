"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[7470],{12964:(e,o,t)=>{t.r(o),t.d(o,{assets:()=>d,contentTitle:()=>i,default:()=>l,frontMatter:()=>n,metadata:()=>a,toc:()=>c});var s=t(74848),r=t(28453);const n={},i="040: Approved keyboards",a={id:"workshop-guidance/devices/RMD_040",title:"040: Approved keyboards",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_040.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_040",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_040",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_040.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"039: Screen capture and Google Assistant",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_039"},next:{title:"041: Require device lock",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_041"}},d={},c=[{value:"Overview",id:"overview",level:2},{value:"Reference",id:"reference",level:2}];function p(e){const o={a:"a",h1:"h1",h2:"h2",header:"header",li:"li",p:"p",strong:"strong",ul:"ul",...(0,r.R)(),...e.components};return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)(o.header,{children:(0,s.jsx)(o.h1,{id:"040-approved-keyboards",children:"040: Approved keyboards"})}),"\n",(0,s.jsx)(o.h2,{id:"overview",children:"Overview"}),"\n",(0,s.jsxs)(o.p,{children:["Select ",(0,s.jsx)(o.strong,{children:"Require"})," and then specify a list of approved keyboards for this policy.\nUsers who aren't using an approved keyboard receive a prompt to download and install an approved keyboard before they can use the protected app. This setting requires the app to have the Intune SDK for Android version 6.2.0 or later."]}),"\n",(0,s.jsx)(o.p,{children:(0,s.jsx)(o.strong,{children:"Select keyboards to approve"})}),"\n",(0,s.jsx)(o.p,{children:"This option is available when you select Require for the previous option. Choose Select to manage the list of keyboards and input methods that can be used with apps protected by this policy. You can add additional keyboards to the list, and remove any of the default options. You must have at least one approved keyboard to save the setting. Over time, Microsoft may add additional keyboards to the list for new App Protection Policies, which will require administrators to review and update existing policies as needed.\nTo add a keyboard, specify:"}),"\n",(0,s.jsxs)(o.p,{children:[(0,s.jsx)(o.strong,{children:"Name:"})," A friendly name that that identifies the keyboard, and is visible to the user."]}),"\n",(0,s.jsxs)(o.p,{children:[(0,s.jsx)(o.strong,{children:"Package ID:"})," The Package ID of the app in the Google Play store. For example, if the URL for the app in the Play store is ",(0,s.jsx)(o.a,{href:"https://play.google.com/store/details?id=com.contoskeyboard.android.prod",children:"https://play.google.com/store/details?id=com.contoskeyboard.android.prod"}),", then the Package ID is com.contosokeyboard.android.prod. This package ID is presented to the user as a simple link to download the keyboard from Google Play."]}),"\n",(0,s.jsxs)(o.p,{children:[(0,s.jsx)(o.strong,{children:"Note:"})," A user assigned multiple App Protection Policies will be allowed to use only the approved keyboards common to all policies."]}),"\n",(0,s.jsx)(o.h2,{id:"reference",children:"Reference"}),"\n",(0,s.jsxs)(o.ul,{children:["\n",(0,s.jsx)(o.li,{children:(0,s.jsx)(o.a,{href:"https://learn.microsoft.com/en-us/mem/intune/apps/app-protection-policy-settings-android#data-transfer",children:"https://learn.microsoft.com/en-us/mem/intune/apps/app-protection-policy-settings-android#data-transfer"})}),"\n"]})]})}function l(e={}){const{wrapper:o}={...(0,r.R)(),...e.components};return o?(0,s.jsx)(o,{...e,children:(0,s.jsx)(p,{...e})}):p(e)}},28453:(e,o,t)=>{t.d(o,{R:()=>i,x:()=>a});var s=t(96540);const r={},n=s.createContext(r);function i(e){const o=s.useContext(n);return s.useMemo((function(){return"function"==typeof e?e(o):{...o,...e}}),[o,e])}function a(e){let o;return o=e.disableParentContext?"function"==typeof e.components?e.components(r):e.components||r:i(e.components),s.createElement(n.Provider,{value:o},e.children)}}}]);
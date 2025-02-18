"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[970],{92812:(e,n,s)=>{s.r(n),s.d(n,{assets:()=>l,contentTitle:()=>o,default:()=>h,frontMatter:()=>r,metadata:()=>c,toc:()=>a});var i=s(74848),t=s(28453);const r={},o="174: Device config policies through settings catalog",c={id:"workshop-guidance/devices/RMD_174",title:"174: Device config policies through settings catalog",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_174.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_174",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_174",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_174.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"173: AMB provisioning",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_173"},next:{title:"175: Deploy macOS SSO extension",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_175"}},l={},a=[{value:"Overview",id:"overview",level:2},{value:"Steps to Deploy Device Configuration Policies through Settings Catalog",id:"steps-to-deploy-device-configuration-policies-through-settings-catalog",level:3},{value:"Benefits",id:"benefits",level:3},{value:"Drawbacks",id:"drawbacks",level:3},{value:"Possible Impact on End Users",id:"possible-impact-on-end-users",level:3},{value:"Tying to Zero Trust",id:"tying-to-zero-trust",level:3},{value:"Reference",id:"reference",level:2}];function d(e){const n={a:"a",h1:"h1",h2:"h2",h3:"h3",header:"header",li:"li",ol:"ol",p:"p",strong:"strong",ul:"ul",...(0,t.R)(),...e.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(n.header,{children:(0,i.jsx)(n.h1,{id:"174-device-config-policies-through-settings-catalog",children:"174: Device config policies through settings catalog"})}),"\n",(0,i.jsx)(n.h2,{id:"overview",children:"Overview"}),"\n",(0,i.jsx)(n.p,{children:"Deploying device configuration policies through the settings catalog for macOS devices in Microsoft Intune allows for granular control over device settings. Here's a detailed overview:"}),"\n",(0,i.jsx)(n.h3,{id:"steps-to-deploy-device-configuration-policies-through-settings-catalog",children:"Steps to Deploy Device Configuration Policies through Settings Catalog"}),"\n",(0,i.jsxs)(n.ol,{children:["\n",(0,i.jsxs)(n.li,{children:["\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Access Intune Admin Center"}),":"]}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsx)(n.li,{children:"Navigate to the Microsoft Intune admin center."}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(n.li,{children:["\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Create a Configuration Profile"}),":"]}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:["Go to ",(0,i.jsx)(n.strong,{children:"Devices"})," > ",(0,i.jsx)(n.strong,{children:"Configuration profiles"})," > ",(0,i.jsx)(n.strong,{children:"Create profile"}),"."]}),"\n",(0,i.jsxs)(n.li,{children:["Select ",(0,i.jsx)(n.strong,{children:"macOS"})," for the platform and ",(0,i.jsx)(n.strong,{children:"Settings catalog"})," for the profile type."]}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(n.li,{children:["\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Configure Settings"}),":"]}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsx)(n.li,{children:"In the settings catalog, browse or search for the settings you want to configure."}),"\n",(0,i.jsx)(n.li,{children:"Add the desired settings to your profile. These can include restrictions on built-in apps, password policies, network configurations, and more."}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(n.li,{children:["\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Assign the Profile"}),":"]}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsx)(n.li,{children:"Assign the profile to the appropriate user or device groups."}),"\n",(0,i.jsx)(n.li,{children:"Review and save the profile."}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(n.li,{children:["\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Monitor Deployment"}),":"]}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsx)(n.li,{children:"Use the Intune admin center to monitor the deployment status and ensure the policies are applied correctly."}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"benefits",children:"Benefits"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Granular Control"}),": Provides detailed control over various device settings, enhancing security and compliance."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Unified Management"}),": Manage all device settings from a single console, simplifying administration."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Scalability"}),": Easily scale policies as the number of macOS devices grows."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Flexibility"}),": Customize settings to meet specific organizational needs."]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"drawbacks",children:"Drawbacks"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Initial Setup Complexity"}),": Configuring detailed settings can be time-consuming and may require a deep understanding of macOS and Intune."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Compatibility Issues"}),": Some settings may not be supported on older macOS versions."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Learning Curve"}),": IT staff may need training to effectively use the settings catalog."]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"possible-impact-on-end-users",children:"Possible Impact on End Users"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Improved Security"}),": Users benefit from enhanced security measures, reducing the risk of data breaches."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Seamless Experience"}),": Properly configured settings can lead to a smoother user experience with fewer disruptions."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Learning Curve"}),": Users may need initial guidance on new policies and procedures."]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"tying-to-zero-trust",children:"Tying to Zero Trust"}),"\n",(0,i.jsx)(n.p,{children:"Deploying device configuration policies through the settings catalog aligns with Zero Trust principles by:"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Continuous Verification"}),": Ensures that devices are continuously verified and compliant before granting access."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Conditional Access"}),": Enforces policies that require devices to meet security standards."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Least Privilege Access"}),": Limits access to resources based on user roles and compliance status."]}),"\n"]}),"\n",(0,i.jsx)(n.h2,{id:"reference",children:"Reference"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:["macOS device settings in Microsoft Intune | Microsoft Learn. ",(0,i.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/configuration/device-restrictions-macos",children:"https://learn.microsoft.com/en-us/mem/intune/configuration/device-restrictions-macos"}),"."]}),"\n",(0,i.jsxs)(n.li,{children:["How to Create Device Compliance Policy Settings in Intune. ",(0,i.jsx)(n.a,{href:"https://www.youtube.com/watch?v=Regg-eJgjho",children:"https://www.youtube.com/watch?v=Regg-eJgjho"}),"."]}),"\n",(0,i.jsxs)(n.li,{children:["How to configure Microsoft Intune Device compliance policies step by step guide ! Intune Full Course. ",(0,i.jsx)(n.a,{href:"https://www.youtube.com/watch?v=R3MTyZI5y0A",children:"https://www.youtube.com/watch?v=R3MTyZI5y0A"}),"."]}),"\n",(0,i.jsxs)(n.li,{children:["Configure macOS devices with Microsoft Intune. ",(0,i.jsx)(n.a,{href:"https://www.youtube.com/watch?v=4QcEIMs20dg",children:"https://www.youtube.com/watch?v=4QcEIMs20dg"}),"."]}),"\n",(0,i.jsxs)(n.li,{children:["macOS device feature settings in Microsoft Intune. ",(0,i.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/configuration/macos-device-features-settings",children:"https://learn.microsoft.com/en-us/mem/intune/configuration/macos-device-features-settings"}),"."]}),"\n",(0,i.jsxs)(n.li,{children:["Tasks you can complete using the Settings Catalog in Intune. ",(0,i.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog-common-features",children:"https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog-common-features"}),"."]}),"\n"]})]})}function h(e={}){const{wrapper:n}={...(0,t.R)(),...e.components};return n?(0,i.jsx)(n,{...e,children:(0,i.jsx)(d,{...e})}):d(e)}},28453:(e,n,s)=>{s.d(n,{R:()=>o,x:()=>c});var i=s(96540);const t={},r=i.createContext(t);function o(e){const n=i.useContext(r);return i.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function c(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(t):e.components||t:o(e.components),i.createElement(r.Provider,{value:n},e.children)}}}]);
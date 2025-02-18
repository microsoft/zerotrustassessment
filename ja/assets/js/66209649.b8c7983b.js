"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[4481],{68905:(e,n,s)=>{s.r(n),s.d(n,{assets:()=>c,contentTitle:()=>o,default:()=>h,frontMatter:()=>r,metadata:()=>l,toc:()=>a});var i=s(74848),t=s(28453);const r={},o="177: Firewall",l={id:"workshop-guidance/devices/RMD_177",title:"177: Firewall",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_177.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_177",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_177",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_177.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"176: AV/EDR",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_176"},next:{title:"178: Deploy MDM based policies for EDR/AV",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_178"}},c={},a=[{value:"Overview",id:"overview",level:2},{value:"Steps to Deploy Firewall",id:"steps-to-deploy-firewall",level:3},{value:"Benefits",id:"benefits",level:3},{value:"Drawbacks",id:"drawbacks",level:3},{value:"Possible Impact on End Users",id:"possible-impact-on-end-users",level:3},{value:"Tying to Zero Trust",id:"tying-to-zero-trust",level:3},{value:"Reference",id:"reference",level:2}];function d(e){const n={a:"a",h1:"h1",h2:"h2",h3:"h3",header:"header",li:"li",ol:"ol",p:"p",strong:"strong",ul:"ul",...(0,t.R)(),...e.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(n.header,{children:(0,i.jsx)(n.h1,{id:"177-firewall",children:"177: Firewall"})}),"\n",(0,i.jsx)(n.h2,{id:"overview",children:"Overview"}),"\n",(0,i.jsx)(n.p,{children:"Deploying firewall settings for macOS devices using Microsoft Intune helps enhance security by controlling network traffic. Here's a detailed overview:"}),"\n",(0,i.jsx)(n.h3,{id:"steps-to-deploy-firewall",children:"Steps to Deploy Firewall"}),"\n",(0,i.jsxs)(n.ol,{children:["\n",(0,i.jsxs)(n.li,{children:["\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Access Intune Admin Center"}),":"]}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsx)(n.li,{children:"Navigate to the Microsoft Intune admin center."}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(n.li,{children:["\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Create a Firewall Policy"}),":"]}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:["Go to ",(0,i.jsx)(n.strong,{children:"Endpoint security"})," > ",(0,i.jsx)(n.strong,{children:"Firewall"})," > ",(0,i.jsx)(n.strong,{children:"Create policy"}),"."]}),"\n",(0,i.jsxs)(n.li,{children:["Select ",(0,i.jsx)(n.strong,{children:"macOS"})," for the platform\u2074."]}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(n.li,{children:["\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Configure Firewall Settings"}),":"]}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsx)(n.li,{children:"Define the firewall rules and settings, such as enabling the firewall, configuring inbound and outbound rules, and setting logging options\u2074."}),"\n",(0,i.jsx)(n.li,{children:"You can also use the settings catalog to configure individual firewall settings."}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(n.li,{children:["\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Assign the Policy"}),":"]}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsx)(n.li,{children:"Assign the firewall policy to the appropriate user or device groups."}),"\n",(0,i.jsx)(n.li,{children:"Review and save the policy."}),"\n"]}),"\n"]}),"\n",(0,i.jsxs)(n.li,{children:["\n",(0,i.jsxs)(n.p,{children:[(0,i.jsx)(n.strong,{children:"Monitor Deployment"}),":"]}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsx)(n.li,{children:"Use the Intune admin center to monitor the deployment status and ensure the policies are applied correctly."}),"\n"]}),"\n"]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"benefits",children:"Benefits"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Enhanced Security"}),": Controls network traffic to and from macOS devices, reducing the risk of unauthorized access."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Unified Management"}),": Manage firewall settings alongside other device configurations in Intune."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Compliance"}),": Helps ensure devices comply with organizational security policies."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Scalability"}),": Easily scale policies as the number of macOS devices grows."]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"drawbacks",children:"Drawbacks"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Initial Setup Complexity"}),": Configuring detailed firewall settings can be time-consuming and may require a deep understanding of macOS and Intune\u2074."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Compatibility Issues"}),": Some settings may not be supported on older macOS versions."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Learning Curve"}),": IT staff may need training to effectively manage firewall settings."]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"possible-impact-on-end-users",children:"Possible Impact on End Users"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Improved Security"}),": Users benefit from enhanced protection against network threats, reducing the risk of data breaches."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Seamless Experience"}),": Properly configured settings can lead to a smoother user experience with fewer disruptions."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Learning Curve"}),": Users may need initial guidance on new policies and procedures."]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"tying-to-zero-trust",children:"Tying to Zero Trust"}),"\n",(0,i.jsx)(n.p,{children:"Deploying firewall settings for macOS devices aligns with Zero Trust principles by:"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Continuous Verification"}),": Ensures that devices are continuously verified and compliant before granting access."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Conditional Access"}),": Enforces policies that require devices to meet security standards."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Least Privilege Access"}),": Limits access to resources based on user roles and compliance status."]}),"\n"]}),"\n",(0,i.jsx)(n.h2,{id:"reference",children:"Reference"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:["Manage firewall settings with endpoint security policies in Microsoft .... ",(0,i.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/endpoint-security-firewall-policy",children:"https://learn.microsoft.com/en-us/mem/intune/protect/endpoint-security-firewall-policy"}),"."]}),"\n",(0,i.jsxs)(n.li,{children:["How to Configure macOS Firewall Settings with Intune - Prajwal Desai. ",(0,i.jsx)(n.a,{href:"https://www.prajwaldesai.com/configure-macos-firewall-settings-with-intune/",children:"https://www.prajwaldesai.com/configure-macos-firewall-settings-with-intune/"}),"."]}),"\n",(0,i.jsxs)(n.li,{children:["Learn to master and manage macOS devices with Microsoft Intune - Intro (1/10). ",(0,i.jsx)(n.a,{href:"https://www.youtube.com/watch?v=wzcUYbb7OQo",children:"https://www.youtube.com/watch?v=wzcUYbb7OQo"}),"."]}),"\n",(0,i.jsxs)(n.li,{children:["How to Enroll MAC Device to Microsoft Intune Portal Step by Step Guide ! Intune Device Enrollment.. ",(0,i.jsx)(n.a,{href:"https://www.youtube.com/watch?v=jLhU3j3QHeI",children:"https://www.youtube.com/watch?v=jLhU3j3QHeI"}),"."]}),"\n",(0,i.jsxs)(n.li,{children:["macOS management with Microsoft Intune | Deployment, single sign-on, settings, apps & DDM. ",(0,i.jsx)(n.a,{href:"https://www.youtube.com/watch?v=M03evxCqwKo",children:"https://www.youtube.com/watch?v=M03evxCqwKo"}),"."]}),"\n",(0,i.jsxs)(n.li,{children:["Configure endpoint protection on macOS devices with Microsoft Intune .... ",(0,i.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/endpoint-protection-macos",children:"https://learn.microsoft.com/en-us/mem/intune/protect/endpoint-protection-macos"}),"."]}),"\n"]})]})}function h(e={}){const{wrapper:n}={...(0,t.R)(),...e.components};return n?(0,i.jsx)(n,{...e,children:(0,i.jsx)(d,{...e})}):d(e)}},28453:(e,n,s)=>{s.d(n,{R:()=>o,x:()=>l});var i=s(96540);const t={},r=i.createContext(t);function o(e){const n=i.useContext(r);return i.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function l(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(t):e.components||t:o(e.components),i.createElement(r.Provider,{value:n},e.children)}}}]);
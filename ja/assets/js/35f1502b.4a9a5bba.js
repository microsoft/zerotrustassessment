"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[7167],{72371:(e,n,i)=>{i.r(n),i.d(n,{assets:()=>c,contentTitle:()=>r,default:()=>p,frontMatter:()=>s,metadata:()=>l,toc:()=>a});var t=i(74848),o=i(28453);const s={},r="148: WDAC / App Control",l={id:"workshop-guidance/devices/RMD_148",title:"148: WDAC / App Control",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_148.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_148",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_148",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_148.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"147: LOB Apps via Intune",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_147"},next:{title:"149: WIP for Enrolled",permalink:"/zerotrustassessment/ja/docs/workshop-guidance/devices/RMD_149"}},c={},a=[{value:"Overview",id:"overview",level:2},{value:"Benefits",id:"benefits",level:3},{value:"Drawbacks",id:"drawbacks",level:3},{value:"Impact on End Users",id:"impact-on-end-users",level:3},{value:"Steps to Deploy WDAC",id:"steps-to-deploy-wdac",level:3},{value:"Tying to Zero Trust",id:"tying-to-zero-trust",level:3},{value:"Reference",id:"reference",level:2}];function d(e){const n={a:"a",h1:"h1",h2:"h2",h3:"h3",header:"header",li:"li",ol:"ol",p:"p",strong:"strong",ul:"ul",...(0,o.R)(),...e.components};return(0,t.jsxs)(t.Fragment,{children:[(0,t.jsx)(n.header,{children:(0,t.jsx)(n.h1,{id:"148-wdac--app-control",children:"148: WDAC / App Control"})}),"\n",(0,t.jsx)(n.h2,{id:"overview",children:"Overview"}),"\n",(0,t.jsx)(n.p,{children:"Windows Defender Application Control (WDAC) and Windows App Control are powerful tools for managing and securing applications on Windows devices. Here's a detailed overview:"}),"\n",(0,t.jsx)(n.h3,{id:"benefits",children:"Benefits"}),"\n",(0,t.jsxs)(n.ol,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Enhanced Security"}),": WDAC helps prevent unauthorized applications from running, reducing the risk of malware and other security threats."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Compliance"}),": Helps meet regulatory and organizational security requirements by enforcing strict application control policies."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Centralized Management"}),": Intune allows you to manage WDAC policies from a single console, simplifying administration."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Flexibility"}),": Supports multiple policy formats and configurations, allowing you to tailor policies to your organization's needs."]}),"\n"]}),"\n",(0,t.jsx)(n.h3,{id:"drawbacks",children:"Drawbacks"}),"\n",(0,t.jsxs)(n.ol,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Initial Setup Complexity"}),": Configuring WDAC policies can be complex and time-consuming, especially for large organizations."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Potential for Application Blockage"}),": Legitimate applications might be blocked if not properly whitelisted, requiring careful planning and testing."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Maintenance"}),": Ongoing maintenance is required to update policies and ensure they remain effective."]}),"\n"]}),"\n",(0,t.jsx)(n.h3,{id:"impact-on-end-users",children:"Impact on End Users"}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Improved Security"}),": Users benefit from enhanced security without needing to take additional actions."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Potential Disruption"}),": Users might experience disruption if legitimate applications are blocked, requiring support intervention."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"User Training"}),": Some users might need training to understand the new application control policies."]}),"\n"]}),"\n",(0,t.jsx)(n.h3,{id:"steps-to-deploy-wdac",children:"Steps to Deploy WDAC"}),"\n",(0,t.jsxs)(n.ol,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Plan Your Deployment"}),": Identify the devices you'll manage with WDAC and split them into deployment rings to control the speed and scale of the deployment."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Create a Policy"}),": In Intune, create a new WDAC policy. Navigate to Device configuration > Profiles > Create profile. Choose Windows 10 and later as the platform, and select Endpoint Protection from the profile type drop-down."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Configure Settings"}),": Define the applications and scripts that are allowed to run. You can use built-in policies or create custom policies using OMA-URI settings."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Convert Policy to Binary"}),": Convert your WDAC policy XML to binary using PowerShell, as WDAC policies must be in binary format for deployment."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Deploy the Policy"}),": Assign the policy to the appropriate groups of devices or users. Ensure to test the policy in audit mode before enforcing it to monitor and adjust as needed\xb2."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Monitor and Adjust"}),": Continuously monitor the deployment and make adjustments based on feedback and observed behavior."]}),"\n"]}),"\n",(0,t.jsx)(n.h3,{id:"tying-to-zero-trust",children:"Tying to Zero Trust"}),"\n",(0,t.jsx)(n.p,{children:"Zero Trust is a security model that assumes no implicit trust and continuously verifies every request. Deploying WDAC through Intune aligns with Zero Trust principles by:"}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Ensuring Secure Access"}),": WDAC enforces strict application control, ensuring only trusted applications can run."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Continuous Verification"}),": Regularly updated policies help maintain secure access, aligning with the continuous verification aspect of Zero Trust."]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.strong,{children:"Reducing Attack Surface"}),": By controlling which applications can run, WDAC reduces the potential attack surface."]}),"\n"]}),"\n",(0,t.jsx)(n.h2,{id:"reference",children:"Reference"}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:["Deploy WDAC policies using Mobile Device Management (MDM) - Windows .... ",(0,t.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/windows/security/application-security/application-control/windows-defender-application-control/deployment/deploy-wdac-policies-using-intune",children:"https://learn.microsoft.com/en-us/windows/security/application-security/application-control/windows-defender-application-control/deployment/deploy-wdac-policies-using-intune"})]}),"\n",(0,t.jsxs)(n.li,{children:["Deploying Windows Defender Application Control (WDAC) policies. ",(0,t.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/windows/security/application-security/application-control/windows-defender-application-control/deployment/wdac-deployment-guide",children:"https://learn.microsoft.com/en-us/windows/security/application-security/application-control/windows-defender-application-control/deployment/wdac-deployment-guide"})]}),"\n",(0,t.jsxs)(n.li,{children:["External Blog: Windows Defender Application Control with ConfigMgr & Intune - Adaptiva. ",(0,t.jsx)(n.a,{href:"https://adaptiva.com/blog/windows-defender-application-control-configmgr-intune",children:"https://adaptiva.com/blog/windows-defender-application-control-configmgr-intune"})]}),"\n"]})]})}function p(e={}){const{wrapper:n}={...(0,o.R)(),...e.components};return n?(0,t.jsx)(n,{...e,children:(0,t.jsx)(d,{...e})}):d(e)}},28453:(e,n,i)=>{i.d(n,{R:()=>r,x:()=>l});var t=i(96540);const o={},s=t.createContext(o);function r(e){const n=t.useContext(s);return t.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function l(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(o):e.components||o:r(e.components),t.createElement(s.Provider,{value:n},e.children)}}}]);
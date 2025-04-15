"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[6930],{27595:(e,n,s)=>{s.r(n),s.d(n,{assets:()=>a,contentTitle:()=>c,default:()=>u,frontMatter:()=>t,metadata:()=>o,toc:()=>d});var i=s(74848),r=s(28453);const t={},c="131: MDM based policies for certs",o={id:"workshop-guidance/devices/RMD_131",title:"131: MDM based policies for certs",description:"Overview",source:"@site/docs/workshop-guidance/devices/RMD_131.md",sourceDirName:"workshop-guidance/devices",slug:"/workshop-guidance/devices/RMD_131",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/devices/RMD_131",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/devices/RMD_131.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"130: Windows Update",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/devices/RMD_130"},next:{title:"132: MDM based policies for Wi-Fi",permalink:"/zerotrustassessment/zh-CN/docs/workshop-guidance/devices/RMD_132"}},a={},d=[{value:"Overview",id:"overview",level:2},{value:"Benefits",id:"benefits",level:3},{value:"Drawbacks",id:"drawbacks",level:3},{value:"Impact on End Users",id:"impact-on-end-users",level:3},{value:"Configuring an NDES Server",id:"configuring-an-ndes-server",level:3},{value:"Tying to Zero Trust",id:"tying-to-zero-trust",level:3},{value:"Reference",id:"reference",level:2}];function l(e){const n={a:"a",h1:"h1",h2:"h2",h3:"h3",header:"header",li:"li",ol:"ol",p:"p",strong:"strong",ul:"ul",...(0,r.R)(),...e.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(n.header,{children:(0,i.jsx)(n.h1,{id:"131-mdm-based-policies-for-certs",children:"131: MDM based policies for certs"})}),"\n",(0,i.jsx)(n.h2,{id:"overview",children:"Overview"}),"\n",(0,i.jsx)(n.p,{children:"Deploying certificates to Windows devices using Microsoft Intune is a powerful way to enhance security and streamline authentication processes. Here's a comprehensive overview:"}),"\n",(0,i.jsx)(n.h3,{id:"benefits",children:"Benefits"}),"\n",(0,i.jsxs)(n.ol,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Enhanced Security"}),": Certificates provide a secure method for authentication, reducing the reliance on passwords which can be compromised."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Seamless User Experience"}),": Users can access resources without repeatedly entering credentials, improving productivity."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Compliance"}),": Helps meet regulatory requirements by ensuring secure access to corporate resources."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Centralized Management"}),": Intune allows for centralized deployment and management of certificates, simplifying administration."]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"drawbacks",children:"Drawbacks"}),"\n",(0,i.jsxs)(n.ol,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Complex Setup"}),": Initial configuration, especially for on-premises components like NDES, can be complex and time-consuming."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Maintenance"}),": Ongoing maintenance of the certificate infrastructure is required to ensure continued security and functionality."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Compatibility Issues"}),": Potential compatibility issues with older devices or applications that may not fully support certificate-based authentication."]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"impact-on-end-users",children:"Impact on End Users"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Improved Security"}),": Users benefit from enhanced security without the need for complex passwords."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Reduced Downtime"}),": Properly managed certificates reduce the risk of downtime due to authentication issues."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"User Training"}),": Some users may require training to understand the new authentication process."]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"configuring-an-ndes-server",children:"Configuring an NDES Server"}),"\n",(0,i.jsx)(n.p,{children:"Network Device Enrollment Service (NDES) is used to issue and manage certificates for devices. Here are the basic steps to configure an NDES server:"}),"\n",(0,i.jsxs)(n.ol,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Install NDES"}),": Install the NDES role on a Windows Server."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Configure NDES"}),": Set up the NDES service to communicate with your Certification Authority (CA)."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Integrate with Intune"}),": Configure Intune to use NDES for certificate deployment."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Secure NDES"}),": Ensure the NDES server is secured and accessible only to authorized devices."]}),"\n"]}),"\n",(0,i.jsx)(n.h3,{id:"tying-to-zero-trust",children:"Tying to Zero Trust"}),"\n",(0,i.jsx)(n.p,{children:"Zero Trust is a security model that assumes no implicit trust and continuously verifies every request. Deploying certificates through Intune aligns with Zero Trust principles by:"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Ensuring Secure Access"}),": Certificates provide a secure method for authenticating users and devices."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Continuous Verification"}),": Certificates can be used to continuously verify the identity of users and devices accessing corporate resources."]}),"\n",(0,i.jsxs)(n.li,{children:[(0,i.jsx)(n.strong,{children:"Reducing Attack Surface"}),": By eliminating the need for passwords, certificates reduce the potential attack surface."]}),"\n"]}),"\n",(0,i.jsx)(n.h2,{id:"reference",children:"Reference"}),"\n",(0,i.jsxs)(n.ul,{children:["\n",(0,i.jsxs)(n.li,{children:["Use certificates for authentication in Microsoft Intune. ",(0,i.jsx)(n.a,{href:"https://learn.microsoft.com/en-us/mem/intune/protect/certificates-configure",children:"https://learn.microsoft.com/en-us/mem/intune/protect/certificates-configure"})]}),"\n",(0,i.jsxs)(n.li,{children:["Overview of Certificate Deployment via Intune: ",(0,i.jsx)(n.a,{href:"https://everythingaboutintune.com/2020/06/overview-of-certificate-deployment-via-intune-and-scep-vs-pkcs",children:"https://everythingaboutintune.com/2020/06/overview-of-certificate-deployment-via-intune-and-scep-vs-pkcs"})]}),"\n",(0,i.jsxs)(n.li,{children:["Microsoft Intune Cloud PKI | Richard M. Hicks Consulting, Inc.. ",(0,i.jsx)(n.a,{href:"https://directaccess.richardhicks.com/2024/03/18/microsoft-intune-cloud-pki/",children:"https://directaccess.richardhicks.com/2024/03/18/microsoft-intune-cloud-pki/"})]}),"\n",(0,i.jsx)(n.li,{children:(0,i.jsx)(n.a,{href:"https://docs.microsoft.com/en-us/intune/certificates-scep-configure",children:"https://docs.microsoft.com/en-us/intune/certificates-scep-configure"})}),"\n"]})]})}function u(e={}){const{wrapper:n}={...(0,r.R)(),...e.components};return n?(0,i.jsx)(n,{...e,children:(0,i.jsx)(l,{...e})}):l(e)}},28453:(e,n,s)=>{s.d(n,{R:()=>c,x:()=>o});var i=s(96540);const r={},t=i.createContext(r);function c(e){const n=i.useContext(t);return i.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function o(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(r):e.components||r:c(e.components),i.createElement(t.Provider,{value:n},e.children)}}}]);
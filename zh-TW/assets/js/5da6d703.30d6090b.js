"use strict";(self.webpackChunkztassess=self.webpackChunkztassess||[]).push([[8585],{35998:(e,t,i)=>{i.r(t),i.d(t,{assets:()=>a,contentTitle:()=>l,default:()=>h,frontMatter:()=>r,metadata:()=>o,toc:()=>c});var s=i(74848),n=i(28453);const r={},l="001: Sensitive data discovery",o={id:"workshop-guidance/data/RMT_001",title:"001: Sensitive data discovery",description:"Overview",source:"@site/docs/workshop-guidance/data/RMT_001.md",sourceDirName:"workshop-guidance/data",slug:"/workshop-guidance/data/RMT_001",permalink:"/zerotrustassessment/zh-TW/docs/workshop-guidance/data/RMT_001",draft:!1,unlisted:!1,editUrl:"https://github.com/microsoft/zerotrustassessment/tree/main/src/react/docs/workshop-guidance/data/RMT_001.md",tags:[],version:"current",frontMatter:{},sidebar:"docsSidebar",previous:{title:"Data",permalink:"/zerotrustassessment/zh-TW/docs/category/data"},next:{title:"002: Document / Identify all approved cross-boundary data sharing scenarios",permalink:"/zerotrustassessment/zh-TW/docs/workshop-guidance/data/RMT_002"}},a={},c=[{value:"Overview",id:"overview",level:2},{value:"Reference",id:"reference",level:2},{value:"Additional resources",id:"additional-resources",level:2}];function d(e){const t={a:"a",h1:"h1",h2:"h2",header:"header",li:"li",p:"p",strong:"strong",table:"table",tbody:"tbody",td:"td",th:"th",thead:"thead",tr:"tr",ul:"ul",...(0,n.R)(),...e.components};return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)(t.header,{children:(0,s.jsx)(t.h1,{id:"001-sensitive-data-discovery",children:"001: Sensitive data discovery"})}),"\n",(0,s.jsx)(t.h2,{id:"overview",children:"Overview"}),"\n",(0,s.jsx)(t.p,{children:"The first step in implementing Zero Trust for your data assets is to identify and categorize these assets according to their sensitivity, which encompasses areas like confidentiality, criticality and business impact.\nThe following tools are available for discovering Sensitive Data across the organization:"}),"\n",(0,s.jsxs)(t.ul,{children:["\n",(0,s.jsxs)(t.li,{children:["Out of the box and custom classifiers (A.K.A. Sensitive Information Types). Classifiers enable you to identify documents and emails that contain contents matching certain patterns or criteria.","\n",(0,s.jsxs)(t.ul,{children:["\n",(0,s.jsx)(t.li,{children:"Out of the box classifiers allow you to detect identifiable information corresponding to well-known entities such as people's national identity numbers, bank accounts or drivers licenses."}),"\n",(0,s.jsx)(t.li,{children:"Custom sensitive information types can be created to identify non-standard, business-specific identifiers or other sensitive information, or to customize how standard entities are detected."}),"\n"]}),"\n"]}),"\n",(0,s.jsxs)(t.li,{children:["Advanced classifiers. These include:","\n",(0,s.jsxs)(t.ul,{children:["\n",(0,s.jsx)(t.li,{children:"Exact Data Match for accurately detecting known personal information such as that corresponding to customers or employees."}),"\n",(0,s.jsx)(t.li,{children:"Trainable classifiers (both pre-trained and custom) to detect documents likely to belong to certain categories or classes"}),"\n",(0,s.jsx)(t.li,{children:"Fingerprints to identify documents closely matching the content in well-known documents."}),"\n",(0,s.jsx)(t.li,{children:"Named entities, which can be used to detect people's names, addresses, credentials and other potentially sensitive data."}),"\n"]}),"\n"]}),"\n",(0,s.jsx)(t.li,{children:"Content Explorer and the Content Explorer Export PowerShell tool: Individual data assets matching individual classifiers can be identified and investigated in Content Explorer directly. Alternatively, information about all data assets can be identified and exported using PowerShell and imported into a SIEM tool for further analysis."}),"\n",(0,s.jsx)(t.li,{children:"Activity Explorer: it reflects creation, access and sharing of sensitive information in your environment, allowing you to perform an initial assessment of risky behaviors and actions by your users involving sensitive data."}),"\n",(0,s.jsx)(t.li,{children:"Unified Audit Log and custom tools built on top of it. Every action related to the creation, modification, classification, discovery or sharing of data in a Microsoft 365 tenant is reflected in the Audit Log, which can be connected to a SIEM to help identify the presence of sensitive information and patterns in its exposure and usage."}),"\n"]}),"\n",(0,s.jsx)(t.h2,{id:"reference",children:"Reference"}),"\n",(0,s.jsxs)(t.ul,{children:["\n",(0,s.jsxs)(t.li,{children:["Content Explorer: ",(0,s.jsx)(t.a,{href:"https://learn.microsoft.com/en-us/purview/data-classification-content-explorer",children:"https://learn.microsoft.com/en-us/purview/data-classification-content-explorer"}),"\xa0 \xa0"]}),"\n",(0,s.jsxs)(t.li,{children:["Content Explorer PowerShell: ",(0,s.jsx)(t.a,{href:"https://learn.microsoft.com/en-us/powershell/module/exchange/export-contentexplorerdata",children:"https://learn.microsoft.com/en-us/powershell/module/exchange/export-contentexplorerdata"}),"\xa0 \xa0 \xa0"]}),"\n",(0,s.jsxs)(t.li,{children:["Activity Explorer: ",(0,s.jsx)(t.a,{href:"https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer",children:"https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer"})]}),"\n",(0,s.jsxs)(t.li,{children:["Unified Audit Log: ",(0,s.jsx)(t.a,{href:"https://learn.microsoft.com/en-us/purview/audit-solutions-overview",children:"https://learn.microsoft.com/en-us/purview/audit-solutions-overview"})]}),"\n",(0,s.jsxs)(t.li,{children:["Out of the box Sensitive Information Types: ",(0,s.jsx)(t.a,{href:"https://aka.ms/sensitiveinfotypes",children:"https://aka.ms/sensitiveinfotypes"})]}),"\n",(0,s.jsxs)(t.li,{children:["Custom Sensitive information types: ",(0,s.jsx)(t.a,{href:"https://learn.microsoft.com/en-us/purview/sit-create-a-custom-sensitive-information-type",children:"https://learn.microsoft.com/en-us/purview/sit-create-a-custom-sensitive-information-type"}),"\xa0"]}),"\n",(0,s.jsxs)(t.li,{children:["Exact data matching: ",(0,s.jsx)(t.a,{href:"https://learn.microsoft.com/en-us/purview/sit-learn-about-exact-data-match-based-sits",children:"https://learn.microsoft.com/en-us/purview/sit-learn-about-exact-data-match-based-sits"})]}),"\n",(0,s.jsxs)(t.li,{children:["Trainable classifiers: ",(0,s.jsx)(t.a,{href:"https://learn.microsoft.com/en-us/purview/trainable-classifiers-learn-about",children:"https://learn.microsoft.com/en-us/purview/trainable-classifiers-learn-about"}),"\xa0 \xa0 \xa0"]}),"\n",(0,s.jsxs)(t.li,{children:["Fingerprinting: ",(0,s.jsx)(t.a,{href:"https://learn.microsoft.com/en-us/purview/sit-document-fingerprinting",children:"https://learn.microsoft.com/en-us/purview/sit-document-fingerprinting"}),"\xa0"]}),"\n",(0,s.jsxs)(t.li,{children:["Named Entities: ",(0,s.jsx)(t.a,{href:"https://learn.microsoft.com/en-us/purview/sit-named-entities-learn",children:"https://learn.microsoft.com/en-us/purview/sit-named-entities-learn"})]}),"\n"]}),"\n",(0,s.jsx)(t.h2,{id:"additional-resources",children:"Additional resources"}),"\n",(0,s.jsxs)(t.table,{children:[(0,s.jsx)(t.thead,{children:(0,s.jsxs)(t.tr,{children:[(0,s.jsx)(t.th,{style:{textAlign:"left"},children:(0,s.jsx)(t.strong,{children:"Scenario"})}),(0,s.jsx)(t.th,{style:{textAlign:"left"},children:(0,s.jsx)(t.strong,{children:"Preferred method"})}),(0,s.jsx)(t.th,{style:{textAlign:"left"},children:(0,s.jsx)(t.strong,{children:"Alternative methods (less accurate)"})}),(0,s.jsx)(t.th,{style:{textAlign:"left"},children:(0,s.jsx)(t.strong,{children:"Techniques to reduce false positives"})})]})}),(0,s.jsxs)(t.tbody,{children:[(0,s.jsxs)(t.tr,{children:[(0,s.jsx)(t.td,{style:{textAlign:"left"},children:(0,s.jsx)(t.strong,{children:"Detect PII/PHI for known individuals (customers/patients)"})}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Exact Data Match to data from LoB app extract"}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Custom SITs including employee ID + common PII SITs (e.g. SSN)."}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"If using regular SITs, consider adding requiring the presence of All Full Names, and limiting rules to documents with more than a certain minimum match count."})]}),(0,s.jsxs)(t.tr,{children:[(0,s.jsx)(t.td,{style:{textAlign:"left"},children:(0,s.jsx)(t.strong,{children:"Detect PII/PHI for employees or contractors"})}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Exact Data Match to data from HR system extract"}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Custom SITs including employee ID + Named Entities\xa0 (e.g. all full names) + common PII SITs (e.g. SSN)."}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"If using regular SITs, consider adding requiring the presence of All Full Names, and limiting rules to documents with more than a certain minimum match count."})]}),(0,s.jsxs)(t.tr,{children:[(0,s.jsx)(t.td,{style:{textAlign:"left"},children:(0,s.jsx)(t.strong,{children:"Detect forms with personal data (e.g. sign-up forms, tax forms, account management forms, etc.)"})}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Form fingerprinting + standard SITs or fingerprinting + custom SITs"}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"(Custom SITs) + keywords + OCR (for scanned forms)"}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Use EDM instead of custom SITs if not using fingerprinting."})]}),(0,s.jsxs)(t.tr,{children:[(0,s.jsx)(t.td,{style:{textAlign:"left"},children:(0,s.jsx)(t.strong,{children:"Contracts, legal documents or other business forms"})}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Custom trainable classifiers (+ OCR)"}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"OOB trainable classifiers + OCR"}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Identify documents in your organization that are correctly identified by the OOB trainable classifiers, copy them to a repository and use them to train a custom classifier. This will produce a fine tuned classifier that will better align with your organization's typical terms (e.g. include company names, jargon, boilerplate)."})]}),(0,s.jsxs)(t.tr,{children:[(0,s.jsx)(t.td,{style:{textAlign:"left"},children:(0,s.jsx)(t.strong,{children:"Important contracts or other documents"})}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Trainable classifier + sensitivity label (manually or automatically applied)"}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Trainable classifier + custom SIT (e.g. regex to detect monetary amounts in excess of $100K, or dictionary or EDM with important customer names)"}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:'Identify documents in your organization that are correctly identified by the OOB trainable classifiers, as well as documents manually tagged/labeled as such, copy them to a repository and use them to train a custom classifier. This will produce a fine tuned classifier that will better align with your organization\'s typical terms (e.g. include company names, jargon, boilerplate). You can also combine use of multiple trainable classifiers in a single rule, e.g. "Contracts" and "Documents about Project X" to find documents relevant to both subjects.'})]}),(0,s.jsxs)(t.tr,{children:[(0,s.jsx)(t.td,{style:{textAlign:"left"},children:(0,s.jsx)(t.strong,{children:"General PII or PHI of unknown individuals (e.g. non-customers or prospective customers)"})}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"OOB SITs if available fo the desired PII or custom SITs."}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Manual labeling"}),(0,s.jsxs)(t.td,{style:{textAlign:"left"},children:["Copy and edit an existing SIT to fine tune its keyword requirements. Expand proximity limit requirements for matching content in filled forms in PDF format since content in forms is not stored within the form structure.  Add requirements for named entities such as All Full Names.",(0,s.jsx)("br",{}),'Ensure custom regexes are defined as "word match" or start and end with \\b.']})]}),(0,s.jsxs)(t.tr,{children:[(0,s.jsx)(t.td,{style:{textAlign:"left"},children:(0,s.jsx)(t.strong,{children:"Sensitive conversations of known nature"})}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Custom Trainable classifier trained based on confirmed samples"}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"\xa0"}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Identify in Content Explorer documents with labels that are relevant to those subjects, extract them and use them to train a custom classifier."})]}),(0,s.jsxs)(t.tr,{children:[(0,s.jsx)(t.td,{style:{textAlign:"left"},children:(0,s.jsx)(t.strong,{children:"Sensitive conversations of non-specific nature"})}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Manual labeling (let the user decide)"}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:'Use dictionaries of "hush words" or other relevant keywords which might hint at sensitive subjects.'}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"\xa0"})]}),(0,s.jsxs)(t.tr,{children:[(0,s.jsx)(t.td,{style:{textAlign:"left"},children:(0,s.jsx)(t.strong,{children:"Scanned identity cards (or similar)"})}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"OOB or Custom SITs + OCR"}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Custom SIT with keyword lists present in such documents + OCR"}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Add requirement for Named Entities (names or addresses) if expected to be written in one line in the document."})]}),(0,s.jsxs)(t.tr,{children:[(0,s.jsx)(t.td,{style:{textAlign:"left"},children:(0,s.jsx)(t.strong,{children:"Project data"})}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Location-based labeling (e.g. default label for library)"}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Manual labeling or custom trainable classifiers"}),(0,s.jsx)(t.td,{style:{textAlign:"left"},children:"Once location-based labeling or manual labeling has identified enough relevant documents use those to train a custom classifier."})]})]})]})]})}function h(e={}){const{wrapper:t}={...(0,n.R)(),...e.components};return t?(0,s.jsx)(t,{...e,children:(0,s.jsx)(d,{...e})}):d(e)}},28453:(e,t,i)=>{i.d(t,{R:()=>l,x:()=>o});var s=i(96540);const n={},r=s.createContext(n);function l(e){const t=s.useContext(r);return s.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function o(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(n):e.components||n:l(e.components),s.createElement(r.Provider,{value:t},e.children)}}}]);
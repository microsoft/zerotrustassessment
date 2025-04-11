// @ts-check
// `@type` JSDoc annotations allow editor autocompletion and type checking
// (when paired with `@ts-check`).
// There are various equivalent ways to declare your Docusaurus config.
// See: https://docusaurus.io/docs/api/docusaurus-config

import { themes as prismThemes } from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Microsoft Zero Trust Workshop',
  tagline: 'Check your Microsoft tenant configuration for zero trust readiness.',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://microsoft.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/zerotrustassessment/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'microsoft', // Usually your GitHub org/user name.
  projectName: 'zerotrustassessment', // Usually your repo name.
  trailingSlash: false,

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en', 'ja', 'ko', 'zh-CN', 'zh-TW'],
    localeConfigs: {
      en: { label: 'English' },
      ja: { label: '日本語' },
      ko: { label: '한국어' },
      'zh-CN': { label: '简体中文' },
      'zh-TW': { label: '繁體中文' }
    },
  },

  plugins: [
    './src/plugins/webpack',
    [
      "@gracefullight/docusaurus-plugin-microsoft-clarity",
      { projectId: "o85tf0o62v" },
    ],
  ],

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: './sidebars.js',
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/microsoft/zerotrustassessment/tree/main/src/react/',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      // Replace with your project's social card
      image: 'img/docusaurus-social-card.jpg',
      navbar: {
        title: 'Zero Trust Workshop',
        logo: {
          alt: 'Site Logo',
          src: 'img/logo.svg',
        },
        items: [
          {
            to: 'workshop',
            position: 'left',
            label: 'About the Workshop',
          },
          {
            to: 'guide',
            position: 'left',
            label: 'Plan',
          },
          {
            type: 'dropdown',
            position: 'left',
            label: 'Learn',
            items: [
              {
                label: "Workshop Docs",
                type: 'docSidebar',
                sidebarId: 'docsSidebar'
              },
              {
                label: 'Workshop Videos',
                type: 'doc',
                docId: 'videos/index'
              }
            ]
          },
          {
            type: 'dropdown',
            position: 'left',
            label: 'FAQs',
            items: [
              {
                label: "General FAQs",
                type: 'doc',
                docId: 'zFAQs/generalFAQs'
              },
              {
                label: 'Partner FAQs',
                type: 'doc',
                docId: 'zFAQs/partnerFAQs'
              }
            ]
          },
          // {
          //   to: 'testimonials',
          //   position: 'right',
          //   label: 'Testimonials',
          // },
          {
            type: 'localeDropdown',
            position: 'right',
          },
          // {
          //   to: 'https://aka.ms/zerotrust',
          //   position: 'right',
          //   label: 'Microsoft Zero Trust',
          // },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'Zero Trust Guidance Center',
                to: 'https://learn.microsoft.com/en-us/security/zero-trust/',
              },
              {
                label: 'Zero Trust Partner Kit',
                to: 'https://aka.ms/zero-trust-partner-kit',
              },
              {
                label: 'Zero Trust Asssessment Checks',
                to: '/docs/intro',
              },
              {
                label: 'Zero Trust App Permissions',
                to: '/docs/app-permissions',
              },
            ],
          },
          {
            title: 'Microsoft',
            items: [
              {
                label: 'Microsoft Zero Trust',
                href: 'https://aka.ms/zerotrust',
              },
              {
                label: 'Zero Trust CISO Workshop',
                href: 'https://learn.microsoft.com/security/ciso-workshop/ciso-workshop',
              },
              {
                label: 'Cybersecurity Reference Architectures',
                href: 'https://aka.ms/mcra',
              },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'Privacy',
                href: 'https://go.microsoft.com/fwlink/?LinkId=521839'
              },
              {
                label: 'Terms of Use',
                href: 'https://go.microsoft.com/fwlink/?LinkID=206977'
              },
              {
                label: 'GitHub',
                href: 'https://github.com/microsoft/zerotrustassessment',
              },
            ],
          },
        ],
        copyright: `Built by the Microsoft Security → CxE Team`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
      },
      colorMode: {
        defaultMode: 'light',
        disableSwitch: true,
      },
    }),
};

export default config;

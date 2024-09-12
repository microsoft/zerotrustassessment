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
    locales: ['en'],
  },

  plugins: ['./src/plugins/webpack'],

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
        title: 'Zero Trust Readiness',
        logo: {
          alt: 'Site Logo',
          src: 'img/logo.svg',
        },
        items: [
          {
            to: 'workshop',
            position: 'left',
            label: 'Workshop',
          },
          {
            to: 'assessment',
            position: 'left',
            label: 'Assessment',
          },
          {
            type: 'dropdown',
            position: 'left',
            label: 'Guides',
            items: [
              {
                label: "Workshop Docs",
                type: 'docSidebar',
                sidebarId: 'docsSidebar'
              },
              {
                label: 'Workshop Videos',
                to: 'videos',
              }
            ]
          },
          {
            to: 'testimonials',
            position: 'right',
            label: 'Testimonials',
          },
          {
            to: 'https://aka.ms/zerotrust',
            position: 'right',
            label: 'Microsoft Zero Trust',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'ZT Asssessment Checks',
                to: '/docs/intro',
              },
              {
                label: 'ZT App Permissions',
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
                label: 'GitHub',
                href: 'https://github.com/microsoft/zerotrustassessment',
              },
            ],
          },
        ],
        copyright: `Built by the Microsoft Security → Customer Acceleration Team (CAT)`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
      },
    }),
};

export default config;

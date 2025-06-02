# Website

This is the website code for the ZT Assessment.

Follow the instructions below to run your own instance of the Zero Trust public site. This is an easy way to make changes and test how the site will look before you commit your changes.

# Installation

There are two options here. You can use GitHub codespaces (simple) where everything runs on the browser or you can do local dev where you install node and run everything on your laptop locally.

## Codespaces (recommended for language translations)

- In GitHub select **Code** > **Codespaces** > Create a new one for the first time (or connect if you already created by clicking on the name).

## Local Dev
- Install [node.js](https://nodejs.org/en/download/)

# Running ZT website

- In VS Code (Codespaces or local dev) open a new Terminal (Menu > Terminal > New Terminal)
- Type this command and hit enter → `cd ./src/react'
- ONE TIME SETUP: Run this command to install all dependencies → `npm install`
- Type this command and hit enter to launch site in English → `npm run start`
   - If you want to run the site in a different language (e.g. Japanese) → `npm run start -- --locale ja`
   - Use the right code for the language that you are testing


import './App.css'
import {
  Card,
  Select,
  SelectItem,
  Tab,
  TabGroup,
  TabList,
  TabPanel,
  TabPanels,
  Divider, Grid, Text
} from '@tremor/react';
import ThemeSwitch from "./components/ThemeSwitch";


const assessmentResults = {
  "Tenant": "Contoso"
}

function App() {


  return (
    <>
      <div className="p-4 sm:p-6 lg:p-8">
        <header>
          <div className="sm:flex sm:items-center sm:justify-between">
            <h3 className="text-tremor-title font-semibold text-tremor-content-strong dark:text-dark-tremor-content-strong">
              Zero Trust Assessment
            </h3>
            <div className="mt-4 sm:mt-0 sm:flex sm:items-center sm:space-x-2">
            <Text> {assessmentResults.Tenant} </Text>
            </div>
          </div>
        </header>
        <main>
          <TabGroup>
            <TabList className="mt-6">
              <Tab>Overview</Tab>
              <Tab>Microsoft Entra</Tab>
              <Tab>Microsoft Intune</Tab>
              <Tab>Microsoft Purview</Tab>
            </TabList>
            <TabPanels>
              <TabPanel className="mt-4">
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  <Card className="h-36 rounded-tremor-small p-2">
                    <ContentPlaceholder />
                  </Card>
                  <Card className="h-36 rounded-tremor-small p-2">
                    <ContentPlaceholder />
                  </Card>
                  <Card className="h-36 rounded-tremor-small p-2">
                    <ContentPlaceholder />
                  </Card>
                  <Card className="h-36 rounded-tremor-small p-2">
                    <ContentPlaceholder />
                  </Card>
                </div>
              </TabPanel>
              <TabPanel className="mt-4">
                <Card className="h-72 rounded-tremor-small p-2">
                  <ContentPlaceholder />
                </Card>
              </TabPanel>
            </TabPanels>
          </TabGroup>
        </main>
        <footer>
        <Divider />
        <Grid numItemsSm={1} numItemsLg={1} className="gap-6 mb-6">

          <div className="place-self-end">
            <ThemeSwitch />
          </div>
        </Grid>
        </footer>
      </div>
    </>
  )
}

function ContentPlaceholder() {
  return (
    <div className="relative h-full overflow-hidden rounded bg-gray-50 dark:bg-dark-tremor-background-subtle">
      <svg
        className="absolute inset-0 h-full w-full stroke-gray-200 dark:stroke-gray-700"
        fill="none"
      >
        <defs>
          <pattern
            id="pattern-1"
            x="0"
            y="0"
            width="10"
            height="10"
            patternUnits="userSpaceOnUse"
          >
            <path d="M-3 13 15-5M-5 5l18-18M-1 21 17 3"></path>
          </pattern>
        </defs>
        <rect
          stroke="none"
          fill="url(#pattern-1)"
          width="100%"
          height="100%"
        ></rect>
      </svg>
    </div>
  );
}


export default App

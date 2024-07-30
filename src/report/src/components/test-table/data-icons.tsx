import {
    ArrowDownIcon,
    ArrowRightIcon,
    ArrowUpIcon,
    CheckCircledIcon,
    CrossCircledIcon,
    StopwatchIcon,
  } from "@radix-ui/react-icons"

  export const labels = [
    {
      value: "bug",
      label: "Bug",
    },
    {
      value: "feature",
      label: "Feature",
    },
    {
      value: "documentation",
      label: "Documentation",
    },
  ]

  export const statuses = [
    {
      value: "Passed",
      label: "Passed",
      icon: CheckCircledIcon,
      variant: "default"
    },
    {
      value: "Failed",
      label: "Failed",
      icon: CrossCircledIcon,
      variant: "destructive"
    },
    {
      value: "Skipped",
      label: "Skipped",
      icon: StopwatchIcon,
      variant: "secondary"
    },
  ]

  export const impacts = [
    {
      label: "Low",
      value: "Low",
      icon: ArrowDownIcon,
    },
    {
      label: "Medium",
      value: "Medium",
      icon: ArrowRightIcon,
    },
    {
      label: "High",
      value: "High",
      icon: ArrowUpIcon,
    },
  ]

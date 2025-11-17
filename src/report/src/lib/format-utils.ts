/**
 * Formats a number for display with K suffix for thousands
 * @param value - The number to format
 * @returns Formatted string (e.g., "1.5K", "150K", "999")
 */
export function formatNumber(value: number | undefined | null): string {
  if (value === undefined || value === null || isNaN(value)) {
    return '0';
  }

  if (value < 1000) {
    return value.toLocaleString();
  }

  if (value < 100000) {
    // Show one decimal place for values under 100K
    return `${(value / 1000).toFixed(1)}K`;
  }

  // No decimal for values 100K and above
  return `${Math.round(value / 1000)}K`;
}

/**
 * Get metric descriptions for tooltips
 */
export const metricDescriptions = {
  users: 'Total number of user accounts in the tenant (excluding guests)',
  guests: 'Total number of guest user accounts',
  groups: 'Total number of groups (security, Microsoft 365, etc.)',
  apps: 'Total number of registered applications',
  devices: 'Including both managed and unmanaged devices',
  managed: 'Total number of Intune managed devices'
};

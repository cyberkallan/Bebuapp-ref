const dateFormatter = new Intl.DateTimeFormat("en-GB", {
  dateStyle: "medium",
  timeStyle: "short",
  timeZone: "UTC",
});

export function formatDate(iso: string): string {
  const date = new Date(iso);
  return Number.isNaN(date.getTime()) ? "—" : `${dateFormatter.format(date)} UTC`;
}

/** 3000 bps -> "30%" */
export function formatBps(bps: number): string {
  return `${(bps / 100).toLocaleString("en-GB", { maximumFractionDigits: 2 })}%`;
}

export function formatCoins(coins: number | string): string {
  return `${Number(coins).toLocaleString("en-GB")} coins`;
}

export function humanize(value: string): string {
  return value.toLowerCase().replaceAll("_", " ");
}

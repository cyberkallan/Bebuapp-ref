import { cn } from "cn";

export type PillTone = "success" | "danger" | "warning" | "neutral";

const TONE_CLASSES: Record<PillTone, string> = {
  success: "bg-success/10 text-success border-success/30",
  danger: "bg-destructive/10 text-destructive border-destructive/30",
  warning: "bg-warning/15 text-foreground border-warning/40",
  neutral: "bg-muted text-muted-foreground border-border",
};

const DOT_CLASSES: Record<PillTone, string> = {
  success: "bg-success",
  danger: "bg-destructive",
  warning: "bg-warning",
  neutral: "bg-muted-foreground/60",
};

export function StatusPill({ tone, children, className }: { tone: PillTone; children: React.ReactNode; className?: string }) {
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1.5 rounded-full border px-2 py-0.5 text-xs font-medium",
        TONE_CLASSES[tone],
        className,
      )}
    >
      <span aria-hidden className={cn("size-1.5 rounded-full", DOT_CLASSES[tone])} />
      {children}
    </span>
  );
}

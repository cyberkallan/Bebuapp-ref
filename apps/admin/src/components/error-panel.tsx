import { AlertTriangle } from 'lucide-react';

import type { ApiErrorBody } from '@bebu/shared';

export function ErrorPanel({
  title,
  error,
  hint,
}: {
  title: string;
  error?: ApiErrorBody;
  hint?: React.ReactNode;
}) {
  return (
    <div role="alert" className="rounded-xl border border-destructive/30 bg-destructive/5 p-4">
      <div className="flex items-start gap-3">
        <AlertTriangle className="mt-0.5 size-4 shrink-0 text-destructive" />
        <div className="min-w-0 space-y-1 text-sm">
          <p className="font-medium">{title}</p>
          {error ? (
            <p className="text-muted-foreground">
              {error.message}
              {error.code ? (
                <>
                  {' '}
                  <span className="font-mono text-xs">({error.code})</span>
                </>
              ) : null}
            </p>
          ) : null}
          {error?.requestId ? (
            <p className="font-mono text-xs text-muted-foreground">request {error.requestId}</p>
          ) : null}
          {hint ? <div className="pt-1 text-muted-foreground">{hint}</div> : null}
        </div>
      </div>
    </div>
  );
}

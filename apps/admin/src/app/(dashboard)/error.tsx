'use client';

import { AlertTriangle } from 'lucide-react';
import { useEffect } from 'react';

import { Button } from '@/components/ui/button';

export default function DashboardError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <div className="mx-auto mt-16 max-w-md rounded-xl border p-6 text-center">
      <AlertTriangle className="mx-auto size-6 text-destructive" />
      <h2 className="mt-3 text-lg font-semibold">Something went wrong</h2>
      <p className="mt-1 text-sm text-muted-foreground">
        {error.message || 'The console hit an unexpected error while loading this page.'}
      </p>
      {error.digest ? (
        <p className="mt-2 font-mono text-xs text-muted-foreground">ref {error.digest}</p>
      ) : null}
      <Button className="mt-4" onClick={reset}>
        Try again
      </Button>
    </div>
  );
}

'use client';

import { RefreshCw } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { useTransition } from 'react';

import { Button } from '@/components/ui/button';

export function RefreshButton() {
  const router = useRouter();
  const [pending, start] = useTransition();

  return (
    <Button
      variant="outline"
      size="sm"
      disabled={pending}
      onClick={() => start(() => router.refresh())}
    >
      <RefreshCw data-icon="inline-start" className={pending ? 'animate-spin' : undefined} />
      {pending ? 'Refreshing' : 'Refresh'}
    </Button>
  );
}

import Link from 'next/link';

import { Button } from '@/components/ui/button';

export default function NotFound() {
  return (
    <main className="flex flex-1 items-center justify-center px-4 py-16">
      <div className="max-w-md text-center">
        <p className="font-mono text-xs text-muted-foreground">404</p>
        <h1 className="mt-2 text-xl font-semibold">Page not found</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          The page you asked for does not exist or you do not have access to it.
        </p>
        <Button className="mt-5" render={<Link href="/" />}>
          Back to overview
        </Button>
      </div>
    </main>
  );
}

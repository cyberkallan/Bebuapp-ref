'use client';

import { cn } from 'cn';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

import { NAV_SECTIONS } from '@/components/nav';
import { Tooltip, TooltipContent, TooltipTrigger } from '@/components/ui/tooltip';

export function SidebarNav({ onNavigate }: { onNavigate?: () => void }) {
  const pathname = usePathname();

  return (
    <nav aria-label="Primary" className="flex flex-col gap-5">
      {NAV_SECTIONS.map((section) => (
        <div key={section.title}>
          <p className="px-2 pb-1.5 text-[11px] font-medium tracking-wider text-muted-foreground uppercase">
            {section.title}
          </p>
          <ul className="space-y-0.5">
            {section.items.map((item) => {
              const Icon = item.icon;

              if (item.kind === 'planned') {
                return (
                  <li key={item.label}>
                    <Tooltip>
                      <TooltipTrigger
                        render={
                          <span
                            aria-disabled
                            className="flex cursor-default items-center gap-2.5 rounded-lg px-2 py-1.5 text-sm text-muted-foreground/70"
                          />
                        }
                      >
                        <Icon className="size-4" />
                        <span className="flex-1 truncate">{item.label}</span>
                        <span className="rounded-md border px-1.5 py-px text-[10px] font-medium">
                          {item.stage}
                        </span>
                      </TooltipTrigger>
                      <TooltipContent side="right">
                        Planned for {item.stage.toLowerCase()} of the build.
                      </TooltipContent>
                    </Tooltip>
                  </li>
                );
              }

              const active = item.href === '/' ? pathname === '/' : pathname.startsWith(item.href);
              return (
                <li key={item.href}>
                  <Link
                    href={item.href}
                    onClick={onNavigate}
                    aria-current={active ? 'page' : undefined}
                    className={cn(
                      'flex items-center gap-2.5 rounded-lg px-2 py-1.5 text-sm transition-colors',
                      active
                        ? 'bg-sidebar-accent font-medium text-sidebar-accent-foreground'
                        : 'text-sidebar-foreground/80 hover:bg-sidebar-accent/60 hover:text-sidebar-foreground',
                    )}
                  >
                    <Icon
                      className={cn('size-4', active ? 'text-primary' : 'text-muted-foreground')}
                    />
                    <span className="truncate">{item.label}</span>
                  </Link>
                </li>
              );
            })}
          </ul>
        </div>
      ))}
    </nav>
  );
}

import { createParamDecorator, type ExecutionContext } from '@nestjs/common';

import type { ContextualRequest } from '../../../common/utils/request-context.js';
import type { Principal } from '../principal.js';

/** Injects the resolved {@link Principal}. Only valid on authenticated routes. */
export const CurrentPrincipal = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): Principal => {
    const req = ctx.switchToHttp().getRequest<ContextualRequest>();
    if (!req.principal) throw new Error('CurrentPrincipal used on a route without authentication');
    return req.principal;
  },
);

import { SetMetadata } from '@nestjs/common';

export const REQUIRE_TENANT_KEY = 'tenant:required';

/** Forces X-Tenant-Key even on @Public or admin-scoped routes. */
export const RequireTenant = () => SetMetadata(REQUIRE_TENANT_KEY, true);

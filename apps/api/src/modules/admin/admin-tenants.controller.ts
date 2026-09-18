import { Controller, Get, Ip, Patch, Post, Req } from '@nestjs/common';
import {
  AuditAction,
  type CreateTenantInput,
  Permission,
  type UpdateTenantInput,
  createTenantSchema,
  idSchema,
  updateTenantSchema,
} from '@bebu/shared';
import type { Request } from 'express';
import { z } from 'zod';

import { ValidatedBody, ValidatedParams } from '../../common/decorators/validated.decorator.js';
import { AppException } from '../../common/errors/app.exception.js';
import { getRequestId } from '../../common/utils/request-context.js';
import type { Tenant } from '../../generated/prisma/client.js';
import { AdminScope } from '../auth/decorators/auth-scope.decorator.js';
import { CurrentPrincipal } from '../auth/decorators/current-principal.decorator.js';
import { RequirePermissions } from '../auth/decorators/permissions.decorator.js';
import type { AdminPrincipal } from '../auth/principal.js';
import { TenantsService } from '../tenants/tenants.service.js';
import { AuditLogService } from './audit-log.service.js';

const tenantIdParams = z.object({ tenantId: idSchema });

/** Admin-facing tenant representation (JSON columns expanded with defaults). */
export interface AdminTenantView {
  id: string;
  key: string;
  name: string;
  status: Tenant['status'];
  androidPackageName: string | null;
  iosBundleId: string | null;
  supportedCountries: readonly string[];
  branding: ReturnType<TenantsService['brandingOf']>;
  legal: ReturnType<TenantsService['legalOf']>;
  featureFlags: ReturnType<TenantsService['flagsOf']>;
  pricing: ReturnType<TenantsService['pricingOf']>;
  createdAt: string;
  updatedAt: string;
}

/**
 * Tenant management for the admin panel.
 * SUPER_ADMIN: all tenants. TENANT_ADMIN: only its own tenant (enforced by
 * comparing the principal's tenantId, never by trusting a query parameter).
 */
@Controller('admin/tenants')
@AdminScope()
export class AdminTenantsController {
  constructor(
    private readonly tenants: TenantsService,
    private readonly audit: AuditLogService,
  ) {}

  @Get()
  @RequirePermissions(Permission.TENANT_READ)
  async list(@CurrentPrincipal() principal: AdminPrincipal): Promise<AdminTenantView[]> {
    const all = await this.tenants.list();
    const visible = principal.tenantId ? all.filter((t) => t.id === principal.tenantId) : all;
    return visible.map((t) => this.toView(t));
  }

  @Get(':tenantId')
  @RequirePermissions(Permission.TENANT_READ)
  async get(
    @CurrentPrincipal() principal: AdminPrincipal,
    @ValidatedParams(tenantIdParams) params: z.infer<typeof tenantIdParams>,
  ): Promise<AdminTenantView> {
    this.assertTenantAccess(principal, params.tenantId);
    return this.toView(await this.tenants.requireById(params.tenantId));
  }

  @Post()
  @RequirePermissions(Permission.TENANT_CREATE)
  async create(
    @CurrentPrincipal() principal: AdminPrincipal,
    @ValidatedBody(createTenantSchema) body: CreateTenantInput,
    @Req() req: Request,
    @Ip() ip: string,
  ): Promise<AdminTenantView> {
    const tenant = await this.tenants.create(body);
    await this.audit.record({
      tenantId: tenant.id,
      actor: AuditLogService.actorOf(principal),
      action: AuditAction.TENANT_CREATED,
      targetType: 'Tenant',
      targetId: tenant.id,
      after: this.toView(tenant),
      requestId: getRequestId(req),
      ipAddress: ip,
    });
    return this.toView(tenant);
  }

  @Patch(':tenantId')
  @RequirePermissions(Permission.TENANT_WRITE)
  async update(
    @CurrentPrincipal() principal: AdminPrincipal,
    @ValidatedParams(tenantIdParams) params: z.infer<typeof tenantIdParams>,
    @ValidatedBody(updateTenantSchema) body: UpdateTenantInput,
    @Req() req: Request,
    @Ip() ip: string,
  ): Promise<AdminTenantView> {
    this.assertTenantAccess(principal, params.tenantId);
    if (body.status !== undefined && principal.tenantId) {
      // Only the platform operator may suspend/reactivate an application.
      throw AppException.forbidden();
    }
    const { before, after } = await this.tenants.update(params.tenantId, body);
    await this.audit.record({
      tenantId: after.id,
      actor: AuditLogService.actorOf(principal),
      action: body.status && body.status !== before.status ? AuditAction.TENANT_SUSPENDED : AuditAction.TENANT_UPDATED,
      targetType: 'Tenant',
      targetId: after.id,
      before: this.toView(before),
      after: this.toView(after),
      requestId: getRequestId(req),
      ipAddress: ip,
    });
    return this.toView(after);
  }

  private assertTenantAccess(principal: AdminPrincipal, tenantId: string): void {
    if (principal.tenantId && principal.tenantId !== tenantId) throw AppException.forbidden();
  }

  private toView(t: Tenant): AdminTenantView {
    return {
      id: t.id,
      key: t.key,
      name: t.name,
      status: t.status,
      androidPackageName: t.androidPackageName,
      iosBundleId: t.iosBundleId,
      supportedCountries: t.supportedCountries,
      branding: this.tenants.brandingOf(t),
      legal: this.tenants.legalOf(t),
      featureFlags: this.tenants.flagsOf(t),
      pricing: this.tenants.pricingOf(t),
      createdAt: t.createdAt.toISOString(),
      updatedAt: t.updatedAt.toISOString(),
    };
  }
}

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bin/rails server              # Start dev server on port 3000
bin/rails test                # Run all tests (parallel)
bin/rails test test/models/user_test.rb  # Run a single test file
bin/rails db:migrate          # Run pending migrations
bin/rails db:seed             # Seed the database
bin/rails routes              # Show all API routes
bin/rails console             # Interactive console
bin/rubocop                   # Lint (Rails Omakase style)
bin/brakeman                  # Security scan
```

## Architecture

**Rails 8.0.2 API-only**, Ruby 3.4.4, PostgreSQL. A multi-tenant ERP system for managing employees, work orders, inventory, and invoicing.

### Multi-Tenancy

Every request must include `X-Company-Id` header. `BaseController#current_company` resolves the tenant from this header and scopes all queries to it. Users belong to companies via the `user_companies` join table.

### API Namespace

All endpoints live under `/api/v1/`. The base controller (`app/controllers/api/v1/base_controller.rb`) handles:
- JWT authentication via `Authorization: Bearer <token>` — decoded with `SECRET_KEY_BASE` (HS256, 24h expiry)
- Company scoping (multi-tenant context)
- Standardized error handling via `rescue_from` with `ApiErrors` module in `app/errors/api_errors.rb`
- Sorting via `apply_sort(scope, allowed: %i[...])` — only allowlisted columns accepted
- Pagination via Pagy (`limit` param, max 100); use `paginate_response(@pagy, serialized)` in controllers

The `Authenticable` and `Authorizable` concerns live in `app/controllers/concerns/`. `Authorizable` only provides `require_super_admin!` — role checks beyond that are done inline in controllers.

`AuthenticationController` inherits `ApplicationController` directly (not `BaseController`) since login is public. Login auto-creates an attendance checkin for the day if the user has an associated `Employee` and hasn't checked in yet.

### Domain Model

| Entity | Notes |
|---|---|
| `User` | Roles: `staff`, `manager`, `admin`, `owner`, `super_admin`; uses `has_secure_password` |
| `Company` | Tenant container; plans: `starter`, `business`, `enterprise` |
| `Employee` | Company staff; optional `user` association; `parsed_name_parts` splits `name` for User creation |
| `WorkOrder` | Core work entity; statuses: `pending → in_progress → in_review → completed → cancelled`; priorities: `low/medium/high/urgent` |
| `WorkOrderItem` | Checklist items on a work order; ordered by `position`; `subtotal = unit_price * quantity` |
| `Ticket` | Auto-generated via `after_commit` when a WorkOrder transitions to `completed` and has no ticket yet; folio format `T-000001` |
| `Product` | Inventory item with `StockMovement` sub-resource; has `menu` collection route |
| `Attendance` | Check-in/out records; types: `normal/late/absent` |
| `Unit` | Measurement units for products |

### Key Patterns

**Controllers**: inherit `BaseController`, call `apply_sort` then `pagy`, then `paginate_response`. Multi-step writes go in transactions. `base_scope` private method returns the company-scoped relation used in all actions.

**Serializers** (`app/serializers/`) are plain Ruby classes with `initialize(record, detailed: false)` and `as_json`. Pass `detailed: true` for full nested data (e.g., `WorkOrderSerializer` includes items array only when detailed). Most index actions use Active Model Serializers directly; work orders and tickets use the plain-class serializers.

**Services** are organized into subdirectories:
- `app/services/pdf/` — `TicketPdfService` generates Prawn A4 PDF
- `app/services/email/` — email helpers
- `app/services/users/` — user-related logic
- `app/services/password_reset_service.rb` / `ticket_pdf_service.rb` at root level (legacy stubs)

**Error classes** (`app/errors/api_errors.rb`): `ApiErrors::BadRequestError`, `UnauthorizedError`, `ForbiddenError`, `NotFoundError`, `UnprocessableEntityError` — all inherit `BaseError` and render `{ error: { status, message, details } }`.

**i18n**: Default locale is Spanish (`es`). Error messages and domain labels (work order status/priority, ticket status) are all translated. Locales in `config/locales/es.yml` and `en.yml`.

### WorkOrder → Ticket lifecycle

When a `WorkOrder` status changes to `completed`, an `after_commit` callback calls `generate_ticket!` if no ticket exists yet. The `Ticket` copies the work order `total`, reserves a temp folio UUID, then overwrites it with `T-000001` format in an `after_create` callback. `Ticket#download` renders via `Pdf::TicketPdfService`.

### Background Jobs & Caching

Uses Rails 8 defaults: **Solid Queue** for jobs, **Solid Cache** for caching, **Solid Cable** for ActionCable. Production uses separate databases for primary, cache, queue, and cable — all configured from `DATABASE_URL`.

### File Storage

Active Storage; dev uses local disk. Production supports Cloudinary or S3-compatible (AWS, Backblaze, Supabase) via env vars. `WorkOrder` uses `has_many_attached :attachments`.

### Deployment

Dockerized with Kamal for orchestration. Also has `render.yaml` for Render.com deployment. Health check at `/up`.

## Environment Variables

| Variable | Purpose |
|---|---|
| `DATABASE_URL` | Production DB connection |
| `RAILS_MASTER_KEY` | Credentials decryption |
| `SECRET_KEY_BASE` | JWT signing key |
| `RESEND_API_KEY` / `RESEND_FROM_EMAIL` | Transactional email |
| `FRONTEND_URL` | CORS allowed origin (default: `http://localhost:4200`) |
| Cloud storage keys | Cloudinary or S3-compatible credentials |

# AI-ACC Unknown Registry
> Generated: 2026-09-20

## UNKNOWN Items Requiring Investigation

### UNK-001: Frontend Field-Level Inventory
- **Category**: Fields
- **Status**: NOT_STARTED
- **Description**: Individual field properties (label, type, validation, API mapping) for all 175 pages
- **Reason**: Requires Playwright runtime inspection of each page
- **Resolution**: Run Playwright on each page, inspect DOM elements
- **Priority**: HIGH

### UNK-002: Frontend Action/Button Inventory
- **Category**: Actions
- **Status**: NOT_STARTED
- **Description**: Individual button/action properties (handler, API call, confirmation, side effects) for all pages
- **Reason**: Requires Playwright runtime inspection
- **Resolution**: Run Playwright, capture click handlers and network requests
- **Priority**: HIGH

### UNK-003: API Response Shapes
- **Category**: API
- **Status**: NOT_STARTED
- **Description**: Actual response JSON structure for all 468 endpoints
- **Reason**: Requires API calls to dev environment
- **Resolution**: Run API tests against dev environment
- **Priority**: MEDIUM

### UNK-004: Database Column Details
- **Category**: Database
- **Status**: PARTIAL
- **Description**: Full column definitions (type, constraints, defaults, indexes) for all 117 tables
- **Reason**: Migrations provide CREATE TABLE but some columns added via ALTER TABLE in later migrations
- **Resolution**: Parse full migration chain for each table
- **Priority**: MEDIUM

### UNK-005: Control Plane API Routes
- **Category**: API
- **Status**: NOT_STARTED
- **Description**: Full route inventory for acc-control-plane-api
- **Reason**: Not yet explored
- **Resolution**: Read control plane main.go
- **Priority**: MEDIUM

### UNK-006: Report API Routes
- **Category**: API
- **Status**: NOT_STARTED
- **Description**: Full route inventory for account-report-api
- **Reason**: Not yet explored
- **Resolution**: Read report API main.go
- **Priority**: MEDIUM

### UNK-007: Frontend Component Details
- **Category**: Components
- **Status**: NOT_STARTED
- **Description**: Component props, state management, hook dependencies for 79 components
- **Reason**: Requires deep frontend code analysis
- **Resolution**: Read component files systematically
- **Priority**: LOW

### UNK-008: Validation Matrix
- **Category**: Validation
- **Status**: NOT_STARTED
- **Description**: Frontend vs backend vs database validation comparison for all fields
- **Reason**: Requires both frontend and backend code analysis + runtime testing
- **Resolution**: Compare frontend validation, backend handler validation, DB constraints
- **Priority**: MEDIUM

### UNK-009: Side Effect Matrix
- **Category**: Side Effects
- **Status**: PARTIAL
- **Description**: Complete side effect chain for all actions (direct, indirect, async)
- **Reason**: Some side effects traced via CodeGraph, but not all
- **Resolution**: Complete CodeGraph exploration for all critical actions
- **Priority**: MEDIUM

### UNK-010: Field Lineage
- **Category**: Fields
- **Status**: NOT_STARTED
- **Description**: UI → Frontend State → API → Service → DB trace for all fields
- **Reason**: Requires deep code analysis per field
- **Resolution**: Systematic trace through frontend hooks → API client → backend handler → service → repository → DB
- **Priority**: MEDIUM

### UNK-011: Error Handling Behavior
- **Category**: Error Flow
- **Status**: NOT_STARTED
- **Description**: How each endpoint handles validation failure, HTTP error, timeout, duplicate request
- **Reason**: Requires runtime testing
- **Resolution**: API error injection testing
- **Priority**: LOW

### UNK-012: Tenant Role Defaults
- **Category**: RBAC
- **Status**: PARTIAL
- **Description**: Default permission matrix for seeded roles (admin, user)
- **Reason**: Requires reading seed data or runtime query
- **Resolution**: Read migration seed data for role_permissions
- **Priority**: MEDIUM

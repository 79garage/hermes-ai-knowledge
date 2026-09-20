# AI-ACC System Map
> Generated: 2026-09-20

## Module Dependency Graph

```mermaid
graph TD
    subgraph Frontend["Frontend (Next.js)"]
        WEB[ai-accounting-web]
    end

    subgraph Backend["Backend API (Go)"]
        CORE[ai-accounting-core]
    end

    subgraph Admin["Admin System"]
        CPA[acc-control-plane-api]
        CPW[acc-control-plane-web]
    end

    subgraph ReportService["Report Service"]
        RPT[account-report-api]
    end

    subgraph External["External Services"]
        PG[(PostgreSQL)]
        LLM[LiteLLM Gateway]
        QD[Qdrant RAG]
        S3[MinIO Storage]
        REDIS[(Redis)]
    end

    WEB -->|HTTP/JSON| CORE
    WEB -->|HTTP/JSON| CPA
    CPW -->|HTTP/JSON| CPA
    CORE -->|SQL| PG
    CPA -->|SQL| PG
    CPA -->|Redis| REDIS
    CORE -->|HTTP| LLM
    CORE -->|HTTP| QD
    CORE -->|HTTP| S3
    CORE -->|HTTP| CPA
    RPT -->|SQL| PG
    RPT -->|HTTP| S3
    WEB -->|HTTP| RPT
```

## Internal Module Dependencies

```mermaid
graph LR
    subgraph Sales["Sales Module"]
        SI[Sales Invoice]
        QT[Quotation]
        SO[Sales Order]
        RC[Receipt]
        CDN[Credit/Debit Note]
        BL[Billing]
        DO[Delivery Order]
    end

    subgraph Purchase["Purchase Module"]
        PI[Purchase Invoice]
        PO[Purchase Order]
        GRN[GRN]
        PP[Purchase Payment]
        VCDN[Vendor CDN]
    end

    subgraph Accounting["Accounting Module"]
        JE[Journal Entry]
        COA[Chart of Accounts]
        PE[Posting Engine]
        MC[Monthly Close]
        YEC[Year-End Close]
    end

    subgraph Tax["Tax Module"]
        VAT[VAT Records]
        WHT[WHT Records]
        PP30[PP30 Filing]
        PP36[PP36 Filing]
        WHTC[WHT Certificates]
    end

    subgraph Bank["Bank Module"]
        BA[Bank Accounts]
        BT[Bank Transactions]
        BR[Bank Reconciliation]
        BS[Bank Statements]
    end

    subgraph Inventory["Inventory Module"]
        ST[Stock]
        WH[Warehouse]
        STK[Stock Transfer]
        LC[Landed Cost]
    end

    SI --> JE
    SI --> VAT
    SI --> WHT
    RC --> JE
    CDN --> JE
    PI --> JE
    PI --> VAT
    PP --> JE
    PP --> WHT
    GRN --> ST
    GRN --> JE
    DO --> ST
    PE --> JE
    MC --> JE
    YEC --> JE
    BA --> JE
    BR --> JE
```

## Data Flow: Sales to GL

```mermaid
flowchart TD
    A[Quotation] -->|Approve| B[Sales Order]
    B -->|Create| C[Sales Invoice]
    C -->|Post| D{Posting Engine}
    D -->|Template| E[Journal Entry]
    D -->|Override| E
    D -->|Fallback| E
    E -->|Post| F[General Ledger]
    C -->|VAT| G[VAT Record]
    C -->|WHT| H[WHT Record]
    C -->|Create Receipt| I[Receipt]
    I -->|Post| E
    C -->|Create Delivery| J[Delivery Order]
    J -->|Confirm| K[Stock Movement]
    K -->|COGS| E
```

## Data Flow: Purchase to GL

```mermaid
flowchart TD
    A[Purchase Order] -->|Approve| B[GRN]
    B -->|Confirm| C[Stock Movement]
    B -->|Create| D[Purchase Invoice]
    D -->|Post| E{Posting Engine}
    E -->|Template| F[Journal Entry]
    F -->|Post| G[General Ledger]
    D -->|VAT| H[VAT Record]
    D -->|Create Payment| I[Purchase Payment]
    I -->|Post| F
    I -->|WHT| J[WHT Record]
```

## Data Flow: Document OCR to GL

```mermaid
flowchart TD
    A[Upload Document] -->|OCR| B[Processing]
    B -->|Extract| C[OCR Result]
    C -->|Review| D[Submit Review]
    D -->|Create Entity| E{Entity Type}
    E -->|Sales| F[Sales Invoice]
    E -->|Receipt| G[Receipt]
    E -->|Purchase| H[Purchase Invoice]
    F -->|Auto-Post| I[Journal Entry]
    G -->|Auto-Post| I
    H -->|Auto-Post| I
    I -->|Post| J[General Ledger]
```

## Cross-Module Shared Services

| Service | Used By | Purpose |
|---------|---------|---------|
| PostingEngine | Sales, Purchase, Receipt, Payment, CDN, Payroll, Fixed Asset, Document | Template-driven Dr/Cr rendering |
| DocumentNumberService | All document types | Auto-generated document numbers |
| JournalService | All financial modules | Journal entry CRUD + posting |
| AccountService | All modules | Chart of accounts lookup |
| StockService | Sales, Purchase, GRN, Delivery | Stock movements and costing |
| CompanyService | All modules | Company configuration and settings |

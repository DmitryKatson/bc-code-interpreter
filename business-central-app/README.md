# Code Interpreter for Business Central

## Overview

This Copilot extension enables Business Central users to ask data questions in natural language. The system uses AI to generate Python code, execute it securely, and provide human-friendly answers with visualizations.

Users simply ask questions like "What were my top customers last month?" and receive clear, actionable insights instantly.

## Key Features

- Ask questions in natural language
- Get answers with visualizations when relevant
- Access Business Central data via secure API
- Intelligent error handling with automatic retries

## Setup Requirements

- Business Central 2024 Wave 2/v26.0+
- Azure OpenAI service (GPT-4 recommended)
- Azure Function App (Python runtime)

## Quick Setup

1. **Azure OpenAI**: Create a resource, deploy a model, note endpoint/key
2. **Azure Function**: Deploy the companion app with BC API credentials
3. **Extension Setup**: Configure OpenAI and Function details in the setup page
4. **Enable Copilot**: Activate the capability in BC settings

## Using the Extension

1. Open "Ask Code Interpreter" page
2. Type your business question
3. Click "Generate"
4. View your answer with any visualizations

## Example Questions

- "What were my top 5 customers by sales last quarter?"
- "Show me inventory items with highest turnover as a chart"
- "Analyze overdue invoices trend over the past 6 months"

## Adding Custom Instructions

You can customize the AI's behavior and add domain-specific knowledge in two ways:

### Method 1: Knowledge Folder (Recommended)

Add your custom instructions as text or markdown files in the `knowledge` folder:

1. Create files in the `knowledge` folder with `.txt` or `.md` extensions
2. Include business rules, custom API definitions, or specific instructions
3. The AI will automatically include this context when generating code

Example knowledge file (`knowledge/custom-apis.md`):
```markdown
# Custom APIs

## Brewery Management APIs

### Beer Production API
- Endpoint: `contoso/brewery/v1.0/companies({companyId})/beerProduction`
- Returns: Production batches with fermentation data
- Key fields: batchNumber, beerType, productionDate, fermentationDays, alcoholContent

### Quality Control API  
- Endpoint: `contoso/brewery/v1.0/companies({companyId})/qualityTests`
- Returns: Quality test results for beer batches
- Key fields: batchNumber, testDate, testType, result, passedQuality

### Inventory Tracking API
- Endpoint: `contoso/brewery/v1.0/companies({companyId})/rawMaterials`
- Returns: Raw material inventory (hops, malt, yeast)
- Key fields: materialType, quantity, expirationDate, supplier

## Usage Instructions
- Always filter production data by date ranges for performance
- Use batchNumber to link production, quality, and inventory data
- Standard Business Central APIs handle sales and financial data
```

### Method 2: Event Subscription (Advanced)

Subscribe to integration events for dynamic context generation:

```al
[EventSubscriber(ObjectType::Codeunit, Codeunit::"GPT Code Interp Python Gen", 'OnAfterGetAdditionalContext', '', false, false)]
local procedure OnAfterGetAdditionalContext(var Context: TextBuilder)
begin
    Context.AppendLine('Custom business logic:');
    Context.AppendLine('- Use customer payment terms for analysis');
    Context.AppendLine('- Filter out test customers (code starts with TEST)');
end;
```

Available events:
- `OnBeforeGetAdditionalContext` - Replace entire context (with handled pattern)
- `OnAfterGetAdditionalContext` - Add to existing context
- `OnBeforeGetAdditionalContextFromKnowledge` - Replace knowledge loading
- `OnAfterGetAdditionalContextFromKnowledge` - Modify loaded knowledge

## Technical Notes

- Secure execution: All code runs in your Azure subscription
- Data privacy: No business data sent to external services
- Output format: Text answers with optional visualizations

## Troubleshooting

If issues occur, check:
- Azure OpenAI and Function settings
- Copilot capability activation
- Function URL format (should include `/api/execute`)

## Support

For help, contact dmitry@katson.com

---

*Powered by Azure OpenAI, Python, and Business Central* 
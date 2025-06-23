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

Example knowledge file (`knowledge/demo-api-guide.md`):
```markdown
# Demo API Guide for Code Interpreter

## Custom APIs

### Manufacturing Production API
- **Endpoint**: `contoso/manufacturing/v1.0/companies({companyId})/productionOrders`
- **Returns**: Production orders with detailed manufacturing data
- **Key fields**: orderNumber, itemNumber, plannedQuantity, actualQuantity, startDate, endDate, status

### Quality Assurance API
- **Endpoint**: `contoso/quality/v1.0/companies({companyId})/qualityInspections`
- **Returns**: Quality inspection results for manufactured items
- **Key fields**: inspectionId, orderNumber, itemNumber, inspectionDate, inspectorId, result, defectsFound

## Example Queries

### Production Performance Analysis
**User Question**: "Show me production efficiency for finished orders this year"
**Endpoint**: `contoso/manufacturing/v1.0/companies({companyId})/productionOrders?$filter=status eq 'Finished' and endDate ge 2024-01-01&$select=orderNumber,itemNumber,plannedQuantity,actualQuantity,startDate,endDate`

### Quality Inspection Summary
**User Question**: "What's our quality inspection pass rate for this quarter?"
**Endpoint**: `contoso/quality/v1.0/companies({companyId})/qualityInspections?$filter=inspectionDate ge 2024-01-01&$select=inspectionId,orderNumber,itemNumber,result,defectsFound`
```

### Method 2: Event Subscription (Advanced)

Subscribe to integration events for dynamic context generation:

```al
[EventSubscriber(ObjectType::Codeunit, Codeunit::"GPT Code Interp Python Gen", 'OnAfterGetAdditionalContext', '', false, false)]
local procedure OnAfterGetAdditionalContext(UserQuestion: Text; var Context: TextBuilder)
begin
    Context.AppendLine('Custom business logic:');
    Context.AppendLine('- Use customer payment terms for analysis');
    Context.AppendLine('- Filter out test customers (code starts with TEST)');
end;

[EventSubscriber(ObjectType::Codeunit, Codeunit::"GPT Code Interp Python Gen", 'OnBeforeAddResourceToKnowledge', '', false, false)]
local procedure OnBeforeAddResourceToKnowledge(UserQuestion: Text; ResourceName: Text; ResourceContent: Text; var Knowledge: TextBuilder; var Handled: Boolean)
begin
    // Skip certain knowledge files based on the user's question
    if (StrPos(LowerCase(UserQuestion), 'beer') > 0) and (ResourceName = 'financial-rules.md') then
        Handled := true; // Skip financial rules for beer-related questions
end;

[EventSubscriber(ObjectType::Codeunit, Codeunit::"GPT Code Interp Python Gen", 'OnAfterGetParentEntitySetName', '', false, false)]
local procedure OnAfterGetParentEntitySetName(PageMetadataRec: Record "Page Metadata"; var ParentEntitySetName: Text)
begin
    // Add custom parent-child entity relationships
    case LowerCase(PageMetadataRec.EntitySetName) of
        'customOrderLines':
            ParentEntitySetName := 'customOrders';
        'projectTaskLines':
            ParentEntitySetName := 'projectTasks';
    end;
end;
```

Available events:
- `OnBeforeGetAdditionalContext(UserQuestion, Context, Handled)` - Replace entire context (with handled pattern)
- `OnAfterGetAdditionalContext(UserQuestion, Context)` - Add to existing context
- `OnBeforeGetAdditionalContextFromKnowledge(UserQuestion, Knowledge, Handled)` - Replace knowledge loading
- `OnAfterGetAdditionalContextFromKnowledge(UserQuestion, Knowledge)` - Modify loaded knowledge
- `OnBeforeAddResourceToKnowledge(UserQuestion, ResourceName, ResourceContent, Knowledge, Handled)` - Control individual resource inclusion
- `OnAfterAddResourceToKnowledge(UserQuestion, ResourceName, ResourceContent, Knowledge)` - Modify individual resource content
- `OnAfterGetParentEntitySetName(PageMetadataRec, ParentEntitySetName)` - **NEW**: Customize parent-child entity relationships

**Key Features:**
- **Context-Aware**: All events receive the `UserQuestion` parameter for intelligent filtering
- **Granular Control**: Resource-level events allow filtering individual knowledge files
- **Flexible Processing**: Can modify, skip, or enhance content based on the specific question asked
- **Parent-Child Relationships**: **NEW**: Customize API entity parent-child mappings for custom APIs

## Version 1.0.1.1 Changes

### Enhanced Error Analysis
- **Retry Mechanism**: Error analysis now includes up to 3 retry attempts with progressive learning
- **Child Entity Support**: Improved handling of child endpoints that require parent document IDs
- **Metadata Fallback**: Added `$metadata` endpoint as last resort for comprehensive API exploration
- **Better Error Messages**: More informative status updates during error analysis

### API Entity Improvements
- **Parent Entity Mapping**: Added `parentEntitySetName` property to identify child entities
- **Enhanced API Documentation**: Generated API list now includes parent-child relationship information
- **Custom Entity Support**: New event for extending parent-child mappings for custom APIs

### Code Generation Enhancements
- **Parent-Child Awareness**: AI now understands when entities require parent IDs
- **Better URI Generation**: Improved guidance for handling child entities in API calls
- **Performance Optimization**: Enhanced prompts for efficient data retrieval

## Technical Notes

- Secure execution: All code runs in your Azure subscription
- Data privacy: No business data sent to external services
- Output format: Text answers with optional visualizations
- **NEW**: Intelligent retry mechanism for error analysis
- **NEW**: Parent-child entity relationship support

## Troubleshooting

If issues occur, check:
- Azure OpenAI and Function settings
- Copilot capability activation
- Function URL format (should include `/api/execute`)

## Support

For help, contact dmitry@katson.com

---

*Powered by Azure OpenAI, Python, and Business Central* 
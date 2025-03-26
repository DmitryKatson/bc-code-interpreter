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
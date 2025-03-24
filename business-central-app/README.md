# Code Interpreter for Business Central

## Overview

The Code Interpreter Copilot extension for Microsoft Dynamics 365 Business Central enables natural language data analysis by leveraging Azure OpenAI and Azure Functions. Users can ask business questions in plain language, and the system will:

1. Generate Python code to answer the question
2. Execute the code in a secure Azure Function
3. Process Business Central data via API
4. Return results and generate a natural language answer
5. Display the final answer to the user

This extension bridges the gap between powerful data analysis capabilities and everyday business users, making advanced analytics accessible without coding skills.

## Features

- **Natural Language Interface**: Ask complex data questions in plain English
- **Python-Powered Analysis**: Leverages pandas, numpy, and other analytics libraries
- **Secure Cloud Execution**: All code runs in a secure Azure Functions environment
- **Business Central Integration**: Seamless access to your BC data via API
- **Human-Friendly Answers**: Results are automatically translated to natural language

## Prerequisites

- Microsoft Dynamics 365 Business Central (2024 Wave 2/v26.0 or higher)
- Azure subscription with:
  - Azure OpenAI service
  - Azure Function App (Python runtime)
- Business Central environment with API access configured

## Installation

1. Import the extension to your Business Central environment
2. Configure the Azure services as described in the setup section
3. Enable the Copilot capability in Business Central

## Setup

### 1. Azure OpenAI Setup

1. Create an Azure OpenAI resource in your Azure subscription
2. Deploy a model (recommended: GPT-4o or newer)
3. Note your endpoint URL, deployment name, and API key

### 2. Azure Function Setup

1. Deploy the companion Azure Function App (see Azure Function README)
2. Configure the environment variables:
   - `BC_TENANT_ID`: Your AAD tenant ID
   - `BC_CLIENT_ID`: App registration client ID with BC API permissions
   - `BC_CLIENT_SECRET`: Secret for the app registration
3. Note your function URL and function key

### 3. Business Central Extension Setup

1. Open the "Code Interpreter Setup" page in BC
2. Enter your Azure OpenAI details:
   - Endpoint URL
   - Deployment name
   - API key
3. Enter your Azure Function details:
   - Function URL
   - Function key
4. Save your settings

## Usage

1. Open the "Ask Code Interpreter" page
2. Type your business question in natural language
   - Example: "What were my top 5 customers by sales last quarter?"
   - Example: "Show me the inventory items with the highest turnover rate"
   - Example: "Analyze the trend of overdue invoices over the past 6 months"
3. Click "Generate" to process your question
4. Review the human-friendly answer

## Security and Privacy

- All data processing happens in your Azure subscription
- No business data is sent to external services beyond your control
- Azure OpenAI is only used for code generation and result interpretation
- The extension follows Microsoft's responsible AI guidelines

## Troubleshooting

If you encounter issues:

1. Verify your Azure OpenAI and Azure Function settings
2. Check that the Copilot capability is enabled
3. Ensure your Azure Function has access to the Business Central API
4. Review the execution logs in the Azure Function monitoring dashboard

## Extension Architecture

The extension consists of:

1. **Setup Components**:
   - Setup table and page for configuration
   - Registration of Copilot capability

2. **User Interface**:
   - PromptDialog page for user interaction

3. **Processing Pipeline**:
   - Python code generation using LLM
   - Code execution in Azure Function
   - Result summarization for user-friendly output

## License

This extension is provided under the [MIT License](LICENSE).

## Support

For support, please contact dmitry@katson.com.

---

*Powered by Azure OpenAI and Business Central* 
# Azure Function for Business Central Code Interpreter

## Overview

This Azure Function is a core component of the Code Interpreter Copilot extension for Microsoft Dynamics 365 Business Central. It provides a secure cloud execution environment for Python code generated from natural language queries. The function:

1. Receives Python code from the Business Central extension
2. Executes the code in a secure sandbox environment
3. Connects to Business Central API to fetch data
4. Processes data using pandas, numpy, and other data analysis libraries
5. Returns results back to the Business Central extension

The Azure Function acts as the computational bridge between natural language queries and Business Central data, enabling powerful data analysis without exposing sensitive business data outside your Azure subscription.

## Prerequisites

- Azure subscription
- Azure Function App with Python 3.10+ runtime
- App registration in Azure Active Directory with Business Central API permissions
- Business Central environment with API access enabled

## Installation

### 1. Create Azure Function App

1. Go to the Azure portal and create a new Function App
2. Select the following settings:
   - Publish: Code
   - Runtime stack: Python
   - Version: 3.10 or newer
   - Operating System: Linux (recommended) or Windows
   - Plan type: Consumption (serverless) or dedicated plan for higher workloads

### 2. Register App in Azure AD

1. Go to Azure Active Directory in the Azure portal
2. Register a new application
3. Add API permissions for Business Central
   - Microsoft Dynamics 365 Business Central
   - Application permissions: API.ReadWrite.All
4. Create a client secret and note the secret value

### 3. Deploy Function Code

Deploy this code to your Azure Function App using one of these methods:
- Visual Studio Code with Azure Functions extension
- Azure Functions Core Tools
- Azure DevOps pipeline
- GitHub Actions

### 4. Configure Environment Variables

Set the following application settings in your Function App:

| Key | Description |
|-----|-------------|
| `BC_TENANT_ID` | Your Azure AD tenant ID |
| `BC_CLIENT_ID` | Client ID of the app registration |
| `BC_CLIENT_SECRET` | Secret of the app registration |

## API Reference

### Execute Python Code

Executes provided Python code and returns the result.

**Endpoint:** `POST /api/main`

**Request Body:**
```json
{
  "code": "string",  // Python code to execute
  "environment": "string"  // Optional: BC environment name (production, sandbox, etc.)
}
```

**Example Code Input:**
```python
# Fetch customer data
customers = get_bc_data("companies(123456)/customers", "sandbox")
df = pd.DataFrame(customers["value"])

# Calculate total balance
output = df["balance"].sum()
```

**Success Response:**
```json
{
  "result": 14567.23  // Value of the 'output' variable after execution
}
```

**Error Response:**
```
Error: No 'output' variable returned from the script.
```

## Helper Functions

The following helper functions are available in the execution environment:

### `get_bc_data(relative_url, environment=None)`

Fetches data from Business Central API.

- `relative_url`: The relative URL path of the BC API endpoint
- `environment`: Optional environment name (defaults to production if not specified)

**Example:**
```python
sales_invoices = get_bc_data("companies(123456)/salesInvoices", "sandbox")
```

## Available Python Libraries

The Azure Function includes these pre-installed data analysis libraries:

- pandas
- numpy
- matplotlib
- scipy
- scikit-learn
- statsmodels

## Security Considerations

- The function runs in a sandboxed environment with restricted access to system resources
- Dangerous modules like `os`, `sys`, `subprocess` are blocked for security
- All data processing happens within your Azure subscription
- Authentication to Business Central API uses secure OAuth2 authentication
- Function execution timeout is set to 30 seconds by default

## Troubleshooting

1. **Function failing to execute code:**
   - Check Application Insights logs for detailed error messages
   - Verify Python syntax in the generated code
   - Confirm memory/timeout limits are sufficient for the workload

2. **Authentication issues with Business Central API:**
   - Verify environment variables are correctly set
   - Check that app registration has proper permissions
   - Ensure the client secret has not expired

3. **Function timeout errors:**
   - Optimize the Python code for better performance
   - Consider increasing function timeout in host.json
   - For complex operations, upgrade to a premium plan

## Local Development

1. Install Azure Functions Core Tools
2. Clone this repository
3. Create a `local.settings.json` file with required environment variables
4. Run `func start` to start the function locally
5. Use tools like Postman to test API calls

## License

This project is provided under the [MIT License](LICENSE).

## Support

For support, please contact dmitry@katson.com.

---

*Part of the Code Interpreter Copilot extension for Microsoft Dynamics 365 Business Central* 
# Business Central Code Interpreter - Azure Function

A secure Python execution environment for the Business Central Code Interpreter extension. This function enables data analysis on your Business Central data without exposing sensitive information outside your Azure subscription.

## Setup

1. **Deploy with Visual Studio Code**
   - Install [VS Code](https://code.visualstudio.com/) and the [Azure Functions extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions)
   - Clone this repository and open in VS Code
   - Use Azure Functions extension to deploy directly to Azure:
     - Click the Azure icon in the sidebar
     - Select "Deploy to Function App..." 
     - Choose "Create new Function App in Azure..."
     - Select Python runtime (3.10+)
     - Set HTTP trigger with "Function" authentication level
     - Choose a name, region, and plan (Consumption or Premium)

2. **Business Central API Access**
   - *Skip this step if you already have BC API access configured*
   - Register app in Azure AD
   - Add Business Central API permissions (API.ReadWrite.All)
   - Create a client secret

3. **Configure Environment Variables**
   - In the Azure Portal, navigate to your Function App
   - Go to "Settings" > "Configuration" 
   - Add the following Application settings:
     - `BC_TENANT_ID`: Your Azure AD tenant ID
     - `BC_CLIENT_ID`: Client ID of the app registration
     - `BC_CLIENT_SECRET`: Secret of the app registration
   - Click "Save" when finished

## Usage

**Endpoint:** `POST /api/execute`

**Request:**
```json
{
  "code": "# Your Python code here"
}
```

**Response Format:**
```json
{
  "data": "Your data as text",
  "chart_images": ["base64encoded_image1", "base64encoded_image2"]
}
```

### Example

```python
# Get data from Business Central
data = get_bc_data("v2.0/companies(123456)/salesInvoices", "sandbox")

# Create the output structure
output = {
    "data": {
        "total_invoices": len(data["value"]),
        "total_amount": sum(item["totalAmountIncludingTax"] for item in data["value"])
    },
    "chart_images": []
}
```

## Available Tools

- **Business Central Access**: `get_bc_data(relative_url, environment)`
- **Data Analysis**: pandas, numpy, matplotlib, scikit-learn, statsmodels
- **Visualization**: Generate charts with matplotlib and return as base64-encoded images

## Security

- Sandboxed execution environment
- Restricted access to system resources
- Dangerous Python modules and functions are blocked
- All data processing happens within your Azure subscription

## Troubleshooting

- Check Application Insights logs for detailed error messages
- Verify environment variables are correctly set
- For complex data, convert to simple types or strings before returning

## Support

For support, please contact dmitry@katson.com.

---

*Part of the Code Interpreter extension for Microsoft Dynamics 365 Business Central* 
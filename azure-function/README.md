# Business Central Code Interpreter - Azure Function

A secure Python execution environment for the Business Central Code Interpreter extension. This function enables data analysis on your Business Central data without exposing sensitive information outside your Azure subscription.

## Setup

1. **Create Azure Function App**
   - Runtime: Python 3.10+
   - OS: Linux (recommended)
   - Plan type: Consumption or Premium

2. **Register App in Azure AD**
   - Add Business Central API permissions (API.ReadWrite.All)
   - Create a client secret

3. **Configure Environment Variables**
   - `BC_TENANT_ID`: Your Azure AD tenant ID
   - `BC_CLIENT_ID`: Client ID of the app registration
   - `BC_CLIENT_SECRET`: Secret of the app registration

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
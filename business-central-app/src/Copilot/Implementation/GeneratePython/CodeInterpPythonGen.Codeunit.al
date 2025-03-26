codeunit 50104 "GPT Code Interp Python Gen"
{
    Access = Internal;

    var
        AOAIChatMessages: Codeunit "AOAI Chat Messages";

    procedure GenerateCode(Question: Text; var AzureOpenAI: Codeunit "Azure OpenAi") Result: Text
    var
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        UIHelper: Codeunit "GPT Code Interp UI Helper";
    begin
        UIHelper.ShowStatus('Generating code...');

        // Set lower temperature for more deterministic code generation
        AOAIChatCompletionParams.SetTemperature(1);

        // Add system and user messages
        if AOAIChatMessages.GetHistory().Count() = 0 then begin
            AOAIChatMessages.AddSystemMessage(GetSystemPrompt());
            AOAIChatMessages.AddUserMessage(GetUserPrompt(Question));
        end;

        // Generate completion
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        // Close status
        UIHelper.CloseStatus();

        if AOAIOperationResponse.IsSuccess() then
            exit(AOAIChatMessages.GetLastMessage())
        else
            Error(AOAIOperationResponse.GetError());
    end;

    procedure AddErrorText(Attempt: Integer; ErrorText: Text)
    var
        ErrorPrompt: TextBuilder;
    begin
        ErrorPrompt.AppendLine('Attempt ' + Format(Attempt) + ':');
        ErrorPrompt.AppendLine('The following error occurred while executing the code:');
        ErrorPrompt.AppendLine('<error_message>');
        ErrorPrompt.AppendLine(ErrorText);
        ErrorPrompt.AppendLine('</error_message>');
        ErrorPrompt.AppendLine('Now, you will investigate the issue and use the results to generate corrected Python code that will properly answer the original question.');
        AOAIChatMessages.AddUserMessage(ErrorPrompt.ToText());
    end;

    procedure AddErrorAnalysis(AnalysisCode: Text; ErrorAnalysis: Text)
    var
        ErrorAnalysisPrompt: TextBuilder;
    begin
        ErrorAnalysisPrompt.AppendLine('You generated the following code to investigate the issue:');
        ErrorAnalysisPrompt.AppendLine('<error_analysis_code>');
        ErrorAnalysisPrompt.AppendLine(AnalysisCode);
        ErrorAnalysisPrompt.AppendLine('</error_analysis_code>');
        ErrorAnalysisPrompt.AppendLine('You executed the code and got the following result:');
        ErrorAnalysisPrompt.AppendLine('<error_analysis>');
        ErrorAnalysisPrompt.AppendLine(ErrorAnalysis);
        ErrorAnalysisPrompt.AppendLine('</error_analysis>');
        ErrorAnalysisPrompt.AppendLine('Based on the error analysis above, generate corrected Python code that will properly answer the original question.');
        AOAIChatMessages.AddUserMessage(ErrorAnalysisPrompt.ToText());
    end;

    local procedure GetSystemPrompt(): Text
    begin
        exit(@'
You are a Python code generator designed to help analyze data from Microsoft Dynamics 365 Business Central.

The user will ask a business-related data question.

Your task is to:
1. Generate valid Python code to retrieve and analyze Business Central data.
2. Use the function `get_bc_data(relative_url, environment)` to fetch data.
   - `relative_url` is the Business Central OData endpoint (e.g., `"v2.0/companies({companyId})/items"`).
   - `environment` is a string (e.g., `"sandbox"` or `"production"`), always required.
3. Process the data using available libraries like:
   - `pandas` for dataframes and grouping
   - `numpy`, `matplotlib`, `scikit-learn`, or `statsmodels` if needed
4. Store the final result in a variable named `output`.
   - This can be a string, number, dictionary, or JSON-serializable object.
5. Do NOT include import statements (like `import requests`, `import os`) — these are already handled in the runtime.
6. Do NOT include authentication logic — the system handles it automatically.
7. Do NOT hardcode full API URLs — only use relative API paths.
8. Do NOT use restricted keywords (`os`, `sys`, `subprocess`, `open`, `eval`, `exec`, etc.).
9. Generate only Python code — no explanations or comments unless asked.

Assume that the following packages are pre-installed:
- pandas
- numpy
- matplotlib
- scikit-learn
- statsmodels
- json
- base64

Example usage:
```python
data = get_bc_data("v2.0/companies({companyId})/salesOrders?$filter=postingDate ge 2024-01-01", "sandbox")
df = pd.DataFrame(data["value"])
monthly_total = df.groupby(df["postingDate"].str[:7])["amount"].sum().to_dict()
output = monthly_total
```

### Plot Instructions

If the user asks for a chart, trend, distribution, or any visual data output:
- Use `matplotlib` to generate a PNG plot.
- Save the image using `plt.savefig("chart.png", format="png")`.
- Open the image file in binary mode and encode it using base64.
- Store the base64 string in the `output` variable.

```python
plt.plot(...)
plt.title(...)
plt.tight_layout()
plt.savefig("chart.png", format="png")
with open("chart.png", "rb") as f:
    output = base64.b64encode(f.read()).decode("utf-8")
```

### Output Format

Always assign your result to a variable named `output`.  
You are free to decide what format best describes the answer:
- A simple value or number (e.g. total sales)
- A dictionary or list (e.g. breakdown by category)
- A natural-language string (e.g. `"The total sales in January were $12,000."`)
- A base64-encoded PNG image if the answer is a plot
The `output` variable will be passed to another AI or UI to finalize the response.

### Request URI Generation Guidelines

When generating the `relative_url` used in the `get_bc_data()` function, follow these rules:

1. **For Standard APIs** (use this format by default):
   - Format: `v2.0/companies({companyId})/entityName`
   - Example: `v2.0/companies({companyId})/salesOrders`
   - You can use `$expand` to include related entities:
   - Example: `v2.0/companies({companyId})/salesOrders?$expand=salesOrderLines`

2. **For Custom APIs** (use when a matching custom API is available in the availableEntities list):
   - Format: `{publisher}/{apiGroup}/{apiVersion}/companies({companyId})/{entitySetName}`
   - Example: `contoso/marketing/v1.0/companies({companyId})/campaigns`
   - Use the properties from the appropriate custom API object in the availableEntities array

3. **Query options** can be added to both standard and custom API paths:
   - Use the `$filter` option when date ranges or conditions are mentioned:
     - Example: `?$filter=postingDate ge 2024-01-01 and postingDate le 2024-03-31`
     - Supported operators: `eq`, `ne`, `gt`, `lt`, `ge`, `le`, `and`, `or`
   - You may also use:
     - `$select` to reduce payload size by returning only relevant fields
     - `$orderby` for sorting
     - `$top=N` for limiting results (e.g., top 5 items)
     - `$count=true` to get the total count of records

4. **Extra guidelines:**
   - Ensure that string values in filters are enclosed in single quotes:
     - Example: `?$filter=customerId eq ''C10000''`
   - When multiple query options are used, separate them with `&`:
     - Example: `?$top=10&$filter=postingDate ge 2024-01-01&$select=number,amount`

Start generating the code immediately in response to the user''s question.
Don''t include ```python at the beginning or end of the code. 
Return only the Python code, no other text or comments or explanations. 
');
    end;

    local procedure GetUserPrompt(Question: Text): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
        JsonObj: JsonObject;
        EnvInfoObj: JsonObject;
        AvailableEntitiesArray: JsonArray;
        YamlText: Text;
    begin
        // Create environment information object
        EnvInfoObj.Add('companyId', GetCompanyId());
        EnvInfoObj.Add('environment', EnvironmentInformation.GetEnvironmentName());
        JsonObj.Add('environmentInformation', EnvInfoObj);

        // Add available APIs
        AvailableEntitiesArray := GetAvailableAPIsAsJson();
        JsonObj.Add('availableEntities', AvailableEntitiesArray);

        // Add current date
        JsonObj.Add('currentDate', Format(Today(), 0, '<Year4>-<Month>-<Day>'));

        // Add user question
        JsonObj.Add('userQuestion', Question);

        // Convert to yaml
        JsonObj.WriteToYaml(YamlText);
        exit(YamlText);
    end;

    local procedure GetAvailableAPIsAsJson() ApiArray: JsonArray
    var
        PageMetadataRec: Record "Page Metadata";
    begin
        PageMetadataRec.SetRange(PageType, PageMetadataRec.PageType::API);
        if PageMetadataRec.FindSet() then
            repeat
                AddAPIEntityToJson(ApiArray, PageMetadataRec);
            until PageMetadataRec.Next() = 0;
    end;

    local procedure AddAPIEntityToJson(var ApiArray: JsonArray; PageMetadataRec: Record "Page Metadata")
    begin
        AddStandardAPIEntityToJson(ApiArray, PageMetadataRec);
        AddCustomAPIEntityToJson(ApiArray, PageMetadataRec);
    end;

    local procedure AddStandardAPIEntityToJson(var ApiArray: JsonArray; PageMetadataRec: Record "Page Metadata")
    var
        ApiObj: JsonObject;
    begin
        if not IsStandardAPI(PageMetadataRec) then
            exit;

        if PageMetadataRec.APIGroup = 'automation' then
            exit;

        if PageMetadataRec.APIVersion <> 'v2.0' then
            exit;

        ApiObj.Add('name', PageMetadataRec."Name");
        ApiObj.Add('description', PageMetadataRec.Caption);
        ApiObj.Add('entityName', PageMetadataRec.EntityName);
        ApiObj.Add('entitySetName', PageMetadataRec.EntitySetName);
        ApiObj.Add('isStandardAPI', true);
        ApiObj.Add('sourceTableName', GetSourceTableName(PageMetadataRec.SourceTable));
        ApiArray.Add(ApiObj);
    end;

    local procedure AddCustomAPIEntityToJson(var ApiArray: JsonArray; PageMetadataRec: Record "Page Metadata")
    var
        ApiObj: JsonObject;
    begin
        if IsStandardAPI(PageMetadataRec) then
            exit;

        ApiObj.Add('name', PageMetadataRec."Name");
        ApiObj.Add('description', PageMetadataRec.Caption);
        ApiObj.Add('apiGroup', PageMetadataRec.APIGroup);
        ApiObj.Add('apiPublisher', PageMetadataRec.APIPublisher);
        ApiObj.Add('apiVersion', PageMetadataRec.APIVersion);
        ApiObj.Add('entityName', PageMetadataRec.EntityName);
        ApiObj.Add('entitySetName', PageMetadataRec.EntitySetName);
        ApiObj.Add('isCustomAPI', true);
        ApiObj.Add('sourceTableName', GetSourceTableName(PageMetadataRec.SourceTable));
        ApiArray.Add(ApiObj);
    end;

    local procedure GetCompanyId(): Text
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName);
        exit(TrimGuid(Company.SystemId));
    end;

    local procedure TrimGuid(Id: Guid): Text
    begin
        exit(DelChr(Format(Id), '<>', '{}'));
    end;

    local procedure IsStandardAPI(PageMetadataRec: Record "Page Metadata"): Boolean
    begin
        exit((PageMetadataRec.APIPublisher = 'microsoft') or (PageMetadataRec.APIPublisher = ''));
    end;

    local procedure GetSourceTableName(SourceTableNo: Integer): Text
    var
        TableMetadataRec: Record "Table Metadata";
    begin
        TableMetadataRec.Get(SourceTableNo);
        exit(TableMetadataRec.Name);
    end;
}
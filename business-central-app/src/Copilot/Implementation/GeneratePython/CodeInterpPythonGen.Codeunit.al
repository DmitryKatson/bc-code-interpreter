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

    procedure AddErrorText(ErrorText: Text)
    var
        ErrorPrompt: TextBuilder;
    begin
        ErrorPrompt.AppendLine('The following error occurred while executing the code:');
        ErrorPrompt.AppendLine('<error_message>');
        ErrorPrompt.AppendLine(ErrorText);
        ErrorPrompt.AppendLine('</error_message>');
        AOAIChatMessages.AddUserMessage(ErrorPrompt.ToText());
    end;

    procedure AddErrorAnalysis(ErrorAnalysis: Text)
    var
        ErrorAnalysisPrompt: TextBuilder;
    begin
        ErrorAnalysisPrompt.AppendLine('The following error analysis was generated:');
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
   - `relative_url` is the Business Central OData endpoint (e.g., `"companies({companyId})/items"`).
   - `environment` is a string (e.g., `"sandbox"` or `"production"`), always required.
3. Process the data using available libraries like:
   - `pandas` for dataframes and grouping
   - `numpy`, `matplotlib`, `scikit-learn`, or `statsmodels` if needed
4. Store the final result in a variable named `output`.
   - This can be a string, number, dictionary, or JSON-serializable object.
5. Do NOT include import statements (like `import requests`, `import os`) — these are already handled in the runtime.
6. Do NOT include authentication logic — the system handles it automatically.
7. Do NOT hardcode full API URLs — only use relative API paths (e.g. `"companies({companyId})/salesOrders"`).
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
data = get_bc_data("companies({companyId})/salesOrders?$filter=postingDate ge 2024-01-01", "sandbox")
df = pd.DataFrame(data["value"])
monthly_total = df.groupby(df["postingDate"].str[:7])["amount"].sum().to_dict()
output = monthly_total
```

### Request URI Generation Guidelines

When generating the `relative_url` used in the `get_bc_data()` function, follow these rules:

1. **Always use a relative OData path**, starting from `"companies({companyId})/`".

2. Use the correct entity name based on the users query. Use official entity names from the Microsoft Dynamics 365 Business Central API documentation.

3. Use the `$filter` query option when date ranges or conditions are mentioned:
   - Example: `?$filter=postingDate ge 2024-01-01 and postingDate le 2024-03-31`
   - Supported operators: `eq`, `ne`, `gt`, `lt`, `ge`, `le`, `and`, `or`

4. You may also use:
   - `$select` to reduce payload size by returning only relevant fields
   - `$orderby` for sorting
   - `$top=N` for limiting results (e.g., top 5 items)

5. Ensure that string values in filters are enclosed in single quotes:
   - Example: `?$filter=customerId eq ''C10000''`

6. When in doubt, use a safe default endpoint like:
   `"companies({companyId})/salesOrders?$filter=postingDate ge 2024-01-01"`

Start generating the code immediately in response to the user''s question.
Don''t include ```python at the beginning or end of the code. 
Return only the Python code, no other text or comments or explanations. 
');
    end;

    local procedure GetUserPrompt(Question: Text): Text
    var
        UserPrompt: TextBuilder;
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        UserPrompt.AppendLine('<environmentInformation>');
        UserPrompt.AppendLine('<companyId>' + GetCompanyId() + '</companyId>');
        UserPrompt.AppendLine('<environment>' + EnvironmentInformation.GetEnvironmentName() + '</environment>');
        UserPrompt.AppendLine('</environmentInformation>');
        UserPrompt.AppendLine('<currentDate>' + Format(Today(), 0, '<Year4>-<Month>-<Day>') + '</currentDate>');
        UserPrompt.AppendLine('<userQuestion>');
        UserPrompt.Append(Question);
        UserPrompt.AppendLine('</userQuestion>');
        exit(UserPrompt.ToText());
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
}
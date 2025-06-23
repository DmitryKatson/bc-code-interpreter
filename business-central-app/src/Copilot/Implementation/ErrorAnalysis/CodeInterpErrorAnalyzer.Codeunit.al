codeunit 50107 "GPT Code Interp Error Analyzer"
{
    Access = Internal;

    procedure AnalyzeError(OriginalQuestion: Text; FailedCode: Text; ErrorMessage: Text; var PythonGenerator: Codeunit "GPT Code Interp Python Gen"; var AzureOpenAI: Codeunit "Azure OpenAi");
    var
        PythonExecutor: Codeunit "GPT Code Interp Execute";
        PythonCode: Text;
        Result: Text;
        RetryCount: Integer;
        MaxRetries: Integer;
        CurrentFailedCode: Text;
        CurrentErrorMessage: Text;
        UIHelper: Codeunit "GPT Code Interp UI Helper";
    begin
        MaxRetries := 3;
        RetryCount := 0;
        CurrentFailedCode := FailedCode;
        CurrentErrorMessage := ErrorMessage;

        repeat
            RetryCount += 1;

            PythonCode := GenerateErrorAnalysisCode(OriginalQuestion, CurrentFailedCode, CurrentErrorMessage, AzureOpenAI);

            if PythonExecutor.TryExecuteCode(PythonCode, Result) then begin
                PythonGenerator.AddErrorAnalysis(PythonCode, Result);
                exit;
            end else begin
                // Add error to history
                PythonGenerator.AddErrorText(RetryCount, GetLastErrorText());

                if RetryCount < MaxRetries then begin
                    UIHelper.ShowStatus('Error analysis failed. Retrying with improved approach... (Attempt ' + Format(RetryCount) + '/' + Format(MaxRetries) + ')');

                    // Update for next iteration - use the failed analysis code as the new failed code
                    CurrentFailedCode := PythonCode;
                    CurrentErrorMessage := GetLastErrorText();
                end else begin
                    // Final failure after all retries
                    UIHelper.ShowStatus('Error analysis failed after ' + Format(MaxRetries) + ' attempts. Proceeding with available information.');
                    PythonGenerator.AddErrorAnalysis(PythonCode, 'Error analysis failed: ' + GetLastErrorText());
                end;
            end;
        until RetryCount >= MaxRetries;
    end;

    procedure GenerateErrorAnalysisCode(OriginalQuestion: Text; FailedCode: Text; ErrorMessage: Text; var AzureOpenAI: Codeunit "Azure OpenAi") Result: Text
    var
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
    begin
        // Set lower temperature for more deterministic code generation
        AOAIChatCompletionParams.SetTemperature(0);

        // Add system and user messages
        AOAIChatMessages.AddSystemMessage(GetErrorAnalysisPrompt());
        AOAIChatMessages.AddUserMessage(FormatErrorAnalysisInput(OriginalQuestion, FailedCode, ErrorMessage));

        // Generate completion
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);
        Result := AOAIChatMessages.GetLastMessage().Replace('```python', '').Replace('```', '');

        if AOAIOperationResponse.IsSuccess() then
            exit(Result)
        else
            Error(AOAIOperationResponse.GetError());
    end;

    local procedure GetErrorAnalysisPrompt(): Text
    begin
        exit(@'
You are an assistant responsible for helping debug failed Python scripts for Business Central data analysis.

You will receive:
1. The original user question.
2. The previously generated Python code that failed to execute.
3. The error message that was returned.

Your task is:
- Analyze why the code might have failed.
- Generate new Python code that will help you understand the structure of the Business Central API response.
- This may include inspecting field names, printing the first row, or listing available keys or types.

⚠️ IMPORTANT PERFORMANCE GUIDELINE: When exploring data, NEVER request full datasets! ⚠️
- Always limit your requests to just 1 row or metadata/keys
- Use $top=1 in queries or only process the first item from results
- Avoid operations that would process or return large datasets

⚠️ Do NOT regenerate the original analysis code yet.

Instead:
- Determine the error type and use one of these approaches:

  A) For API or endpoint not found errors:
     - Use `get_bc_data("v2.0", environment)` to list all available APIs
     - This will return metadata about all available endpoints
     - Example: `data = get_bc_data("v2.0", "sandbox")`

  B) For field-level errors (missing fields, wrong data types):
     - Use `get_bc_data(relative_url, environment)` to re-fetch the data WITH A LIMIT
     - Add `?$top=1` to the URL to get just one record
     - Inspect the structure by examining keys and first record only
     - Example: `data = get_bc_data("v2.0/companies({companyId})/salesOrders?$top=1", "sandbox")`

  C) For child endpoints that require parent document IDs (like salesInvoiceLines, salesOrderLines, etc.):
     - First, get a valid parent document ID by querying the parent endpoint with $top=1
     - Then use that ID to explore the child endpoint structure
     - Example approach:
       ```python
       # Step 1: Get a valid sales invoice ID
       invoices = get_bc_data("v2.0/companies({companyId})/salesInvoices?$top=1", "sandbox")
       if invoices and len(invoices) > 0:
           invoice_id = invoices[0].get(''id'')
           # Step 2: Explore the lines structure using the valid ID
           lines = get_bc_data(f"v2.0/companies({{companyId}})/salesInvoices({invoice_id})/salesInvoiceLines?$top=1", "sandbox")
       ```
     - Alternative: Use the parent endpoint to understand the relationship structure
     - For endpoints like "salesInvoiceLines", you need a valid "salesInvoices" ID first

  D) ⚠️ LAST RESORT: Use $metadata for detailed entity and field information ⚠️
     - Use `get_bc_data("v2.0/$metadata", environment)` to get XML metadata about all entities and fields
     - This returns comprehensive information but is very large - use ONLY when other approaches fail
     - Parse the XML response to find specific entity definitions, field names, and data types
     - Example: `data = get_bc_data("v2.0/$metadata", "sandbox")`
     - Use this sparingly as it returns extensive metadata for the entire API

- Your goal is to explore the API structure — not the full dataset.
- Minimize data transfer by only requesting exactly what you need to diagnose the issue.
- Store your result in `output`.

⚠️ CRITICAL REQUIREMENT: ALWAYS assign your final result to a variable named `output` using this EXACT structure: ⚠️
```python
output = {
    "data": result,  # Your diagnostic data (dictionary, list, etc.)
    "chart_images": []  # Always include this (empty array for diagnostic code)
}
```

Don''t include ```python at the beginning or end of the code. 
Return only the Python code, no other text or comments or explanations.
');
    end;

    local procedure FormatErrorAnalysisInput(OriginalQuestion: Text; FailedCode: Text; ErrorMessage: Text): Text
    var
        InputBuilder: TextBuilder;
    begin
        InputBuilder.AppendLine('<originalQuestion>');
        InputBuilder.AppendLine(OriginalQuestion);
        InputBuilder.AppendLine('</originalQuestion>');
        InputBuilder.AppendLine('<failedCode>');
        InputBuilder.AppendLine(FailedCode);
        InputBuilder.AppendLine('</failedCode>');
        InputBuilder.AppendLine('<errorMessage>');
        InputBuilder.AppendLine(ErrorMessage);
        InputBuilder.AppendLine('</errorMessage>');
        InputBuilder.AppendLine('Focus on understanding why the code failed and generate diagnostic code to explore the data structure.');

        exit(InputBuilder.ToText());
    end;
}
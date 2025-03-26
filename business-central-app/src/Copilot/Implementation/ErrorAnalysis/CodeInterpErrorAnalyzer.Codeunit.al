codeunit 50107 "GPT Code Interp Error Analyzer"
{
    Access = Internal;

    procedure AnalyzeError(OriginalQuestion: Text; FailedCode: Text; ErrorMessage: Text; var PythonGenerator: Codeunit "GPT Code Interp Python Gen"; var AzureOpenAI: Codeunit "Azure OpenAi");
    var
        PythonExecutor: Codeunit "GPT Code Interp Execute";
        PythonCode: Text;
        Result: Text;
    begin
        PythonCode := GenerateErrorAnalysisCode(OriginalQuestion, FailedCode, ErrorMessage, AzureOpenAI);
        if not PythonExecutor.TryExecuteCode(PythonCode, Result) then
            Error('Failed to execute the error analysis code. Error: ' + GetLastErrorText());

        PythonGenerator.AddErrorAnalysis(PythonCode, Result);
    end;

    procedure GenerateErrorAnalysisCode(OriginalQuestion: Text; FailedCode: Text; ErrorMessage: Text; var AzureOpenAI: Codeunit "Azure OpenAi") Result: Text
    var
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        UIHelper: Codeunit "GPT Code Interp UI Helper";
    begin
        UIHelper.ShowStatus('Analyzing error...');

        // Set lower temperature for more deterministic code generation
        AOAIChatCompletionParams.SetTemperature(0);

        // Add system and user messages
        AOAIChatMessages.AddSystemMessage(GetErrorAnalysisPrompt());
        AOAIChatMessages.AddUserMessage(FormatErrorAnalysisInput(OriginalQuestion, FailedCode, ErrorMessage));

        // Generate completion
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        // Close status
        UIHelper.CloseStatus();

        if AOAIOperationResponse.IsSuccess() then
            exit(AOAIChatMessages.GetLastMessage())
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

⚠️ Do NOT regenerate the original analysis code yet.

Instead:
- Determine the error type and use one of these approaches:

  A) For API or endpoint not found errors:
     - Use `get_bc_data("v2.0", environment)` to list all available APIs
     - This will return metadata about all available endpoints
     - Example: `data = get_bc_data("v2.0", "sandbox")`

  B) For field-level errors (missing fields, wrong data types):
     - Use `get_bc_data(relative_url, environment)` to re-fetch the data WITHOUT filters
     - Inspect the structure by examining keys and first record
     - Example: `data = get_bc_data("v2.0/companies({companyId})/salesOrders", "sandbox")`

- Your goal is to explore what the API returns — not to compute the business logic.
- Store your result in `output`.

Don''t include ```python at the beginning or end of the code. 
Return only the Python code, no other text or comments or explanations.');
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
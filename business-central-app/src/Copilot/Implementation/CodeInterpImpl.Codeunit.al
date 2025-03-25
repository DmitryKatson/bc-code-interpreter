codeunit 50102 "GPT Code Interp Impl"
{

    procedure GenerateAndExecuteCode(InputText: Text) Result: Text
    var
        AzureOpenAI: Codeunit "Azure OpenAi";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        CopilotSetup: Record "GPT Code Interpreter Setup";
        ExecutionResult: Text;
        FinalAnswer: Text;
    begin
        // TODO: Implement the following steps:
        // 1. Check if Copilot is enabled
        // 2. Set up Azure OpenAI connection
        // 3. Generate Python code using LLM and execute it in Azure Function
        // 4. Generate human-friendly final answer

        // 1. Check if Copilot is enabled
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"GPT Code Interp Copilot") then
            exit('Copilot is not enabled. Please enable it in Copilot & AI capabilities settings.');

        // 2. Set up Azure OpenAI connection
        CopilotSetup.Get();
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"GPT Code Interp Copilot");
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", CopilotSetup.GetAzureOpenAIEndpoint(), CopilotSetup.GetAzureOpenAIDeployment(), CopilotSetup.GetAzureOpenAIKey());

        // 3: Generate Python code using LLM and execute it in Azure Function
        ExecutionResult := GenerateAndExecuteCode(InputText, AzureOpenAI);
        if ExecutionResult = '' then
            exit('Failed to generate and execute code.');

        // 4. Generate human-friendly final answer
        FinalAnswer := GenerateSummary(InputText, ExecutionResult, AzureOpenAI);
        if FinalAnswer = '' then
            exit(ExecutionResult); // Fallback to showing raw result if summary fails

        exit(FinalAnswer);
    end;

    local procedure GenerateAndExecuteCode(InputText: Text; var AzureOpenAI: Codeunit "Azure OpenAi"): Text
    var
        PythonCode: Text;
        ExecutionResult: Text;
        MaxRetries: Integer;
        RetryCount: Integer;
        PythonGenerator: Codeunit "GPT Code Interp Python Gen";
        PythonExecutor: Codeunit "GPT Code Interp Execute";
        PythonErrorAnalyzer: Codeunit "GPT Code Interp Error Analyzer";
        PythonErrorAnalysis: Text;
    begin
        MaxRetries := 3;
        RetryCount := 0;

        repeat
            // Generate Python code using LLM
            PythonCode := PythonGenerator.GenerateCode(InputText, AzureOpenAI);
            if PythonCode = '' then
                Error('Failed to generate Python code for your question.');

            // Execute code in Azure Function
            if not PythonExecutor.TryExecuteCode(PythonCode, ExecutionResult) then begin
                // Analyze error and generate corrected code
                PythonGenerator.AddErrorText(GetLastErrorText());
                PythonErrorAnalyzer.AnalyzeError(InputText, PythonCode, GetLastErrorText(), PythonErrorAnalysis, AzureOpenAI);
                PythonGenerator.AddErrorAnalysis(PythonErrorAnalysis);

                RetryCount += 1;
                if RetryCount >= MaxRetries then
                    Error('Failed to execute the code in Azure Function.');
            end else
                exit(ExecutionResult);
        until RetryCount >= MaxRetries;

        exit(ExecutionResult);
    end;

    local procedure GenerateSummary(Question: Text; ExecutionResult: Text; var AzureOpenAI: Codeunit "Azure OpenAi"): Text
    var
        FinalAnswerGenerator: Codeunit "GPT Code Interp Final Answer";
    begin
        exit(FinalAnswerGenerator.GenerateSummary(Question, ExecutionResult, AzureOpenAI));
    end;
}
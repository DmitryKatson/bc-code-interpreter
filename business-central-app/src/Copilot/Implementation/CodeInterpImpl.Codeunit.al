codeunit 50102 "GPT Code Interp Impl"
{

    procedure GenerateAndExecuteCode(InputText: Text) Result: Text
    var
        AzureOpenAI: Codeunit "Azure OpenAi";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        CopilotSetup: Record "GPT Code Interpreter Setup";
        PythonCode: Text;
        ExecutionResult: Text;
        FinalAnswer: Text;
    begin
        // TODO: Implement the following steps:
        // 1. Check if Copilot is enabled
        // 2. Set up Azure OpenAI connection
        // 3. Generate Python code using LLM
        // 4. Execute code in Azure Function
        // 5. Generate human-friendly final answer

        // 1. Check if Copilot is enabled
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"GPT Code Interp Copilot") then
            exit('Copilot is not enabled. Please enable it in Copilot & AI capabilities settings.');

        // 2. Set up Azure OpenAI connection
        CopilotSetup.Get();
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"GPT Code Interp Copilot");
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", CopilotSetup.GetAzureOpenAIEndpoint(), CopilotSetup.GetAzureOpenAIDeployment(), CopilotSetup.GetAzureOpenAIKey());

        // 3. Generate Python code using LLM
        PythonCode := GeneratePythonCode(InputText, AzureOpenAI);
        if PythonCode = '' then
            exit('Failed to generate Python code for your question.');

        // 4. Execute code in Azure Function
        ExecutionResult := ExecuteCodeInFunction(PythonCode);
        if ExecutionResult = '' then
            exit('Failed to execute the code in Azure Function.');

        // 5. Generate human-friendly final answer
        FinalAnswer := GenerateSummary(InputText, ExecutionResult, AzureOpenAI);
        if FinalAnswer = '' then
            exit(ExecutionResult); // Fallback to showing raw result if summary fails

        exit(FinalAnswer);
    end;

    local procedure GeneratePythonCode(Question: Text; var AzureOpenAI: Codeunit "Azure OpenAi"): Text
    var
        PythonGenerator: Codeunit "GPT Code Interp Python Gen";
    begin
        exit(PythonGenerator.GenerateCode(Question, AzureOpenAI));
    end;

    local procedure ExecuteCodeInFunction(PythonCode: Text): Text
    var
        PythonExecutor: Codeunit "GPT Code Interp Execute";
    begin
        exit(PythonExecutor.ExecuteCode(PythonCode));
    end;

    local procedure GenerateSummary(Question: Text; ExecutionResult: Text; var AzureOpenAI: Codeunit "Azure OpenAi"): Text
    var
        FinalAnswerGenerator: Codeunit "GPT Code Interp Final Answer";
    begin
        exit(FinalAnswerGenerator.GenerateSummary(Question, ExecutionResult, AzureOpenAI));
    end;
}
codeunit 50102 "GPT Code Interp Impl"
{
    var
        UIHelper: Codeunit "GPT Code Interp UI Helper";
        FinalPythonCode: Text;

    procedure GenerateAndExecuteCode(InputText: Text) Result: Text
    var
        AzureOpenAI: Codeunit "Azure OpenAi";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        CopilotSetup: Record "GPT Code Interpreter Setup";
        ExecutionResult: Text;
        FinalAnswer: Text;
        ChartImages: Text;
        ResultInHtml: Text;
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
        UIHelper.ShowStatus('I found everything I needed. Generating final answer...');
        FinalAnswer := GenerateSummary(InputText, ExecutionResult, AzureOpenAI);
        UIHelper.CloseStatus();
        if FinalAnswer = '' then
            exit(ExecutionResult); // Fallback to showing raw result if summary fails

        ResultInHtml := UIHelper.GenerateResultInHtml(FinalAnswer, GetChartImages(ExecutionResult));
        exit(ResultInHtml);
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
        UIHelper: Codeunit "GPT Code Interp UI Helper";
    begin
        MaxRetries := 3;
        RetryCount := 0;
        Clear(FinalPythonCode);

        repeat
            // Generate Python code using LLM
            UIHelper.ShowStatus(StrSubstNo('Generating %1 to answer your question...', GetCodeCharacteristics(RetryCount)));
            PythonCode := PythonGenerator.GenerateCode(InputText, AzureOpenAI);
            SetFinalPythonCode(PythonCode);

            if PythonCode = '' then
                Error('Failed to generate Python code for your question.');

            // Execute code in Azure Function
            UIHelper.ShowStatus('Executing code...');
            if not PythonExecutor.TryExecuteCode(PythonCode, ExecutionResult) then begin
                RetryCount += 1;
                if RetryCount > MaxRetries then
                    continue;

                UIHelper.ShowStatus('Oops! I made a mistake. Let me find a better solution... (Attempt ' + Format(RetryCount) + '/' + Format(MaxRetries) + ')');
                // Analyze error and find a way to fix it
                PythonGenerator.AddErrorText(RetryCount, GetLastErrorText());
                PythonErrorAnalyzer.AnalyzeError(PythonGenerator.GetUserPrompt(InputText), PythonCode, GetLastErrorText(), PythonGenerator, AzureOpenAI);
            end else
                exit(ExecutionResult);

        until RetryCount > MaxRetries;

        Error('I tried to generate the code but failed. Please try to rephrase your question and try again.');
    end;

    local procedure GetCodeCharacteristics(RetryCount: Integer): Text
    begin
        case RetryCount of
            0:
                exit('code');
            1:
                exit('better code');
            2:
                exit('even better code');
            else
                exit('code');
        end;
    end;

    local procedure GenerateSummary(Question: Text; ExecutionResult: Text; var AzureOpenAI: Codeunit "Azure OpenAi"): Text
    var
        FinalAnswerGenerator: Codeunit "GPT Code Interp Final Answer";
        Json: Codeunit Json;
        DataResult: Text;
    begin
        Json.InitializeObject(ExecutionResult);
        Json.GetStringPropertyValueByName('data', DataResult);
        exit(FinalAnswerGenerator.GenerateSummary(Question, DataResult, AzureOpenAI));
    end;

    local procedure GetChartImages(ExecutionResult: Text) ChartImages: Text
    var
        Json: Codeunit Json;
    begin
        Json.InitializeObject(ExecutionResult);
        Json.GetStringPropertyValueByName('chart_images', ChartImages);
    end;

    local procedure SetFinalPythonCode(PythonCode: Text)
    begin
        FinalPythonCode := PythonCode;
    end;

    procedure GetThinkingProcess(): Text
    begin
        exit(UIHelper.GetThinkingProcessInHtml(FinalPythonCode));
    end;
}
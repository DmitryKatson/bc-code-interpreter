codeunit 50106 "GPT Code Interp Final Answer"
{
    Access = Internal;

    procedure GenerateSummary(UserQuestion: Text; ExecutionResult: Text; var AzureOpenAI: Codeunit "Azure OpenAi") Result: Text
    var
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
    begin
        // Set slightly higher temperature for more natural language responses
        AOAIChatCompletionParams.SetTemperature(0.7);

        // Add system and context messages
        AOAIChatMessages.AddSystemMessage(GetSystemPrompt());
        AOAIChatMessages.AddUserMessage(FormatSummaryInput(UserQuestion, ExecutionResult));

        // Generate completion
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        if AOAIOperationResponse.IsSuccess() then
            exit(AOAIChatMessages.GetLastMessage())
        else
            Error(AOAIOperationResponse.GetError());
    end;

    local procedure GetSystemPrompt(): Text
    begin
        exit(@'
You are an assistant that summarizes data for a Business Central user in a clear and helpful way.

Your task:
1. Understand what the user is asking.
2. Interpret the result correctly.
3. Write a short, human-friendly summary that clearly answers the question.
4. Use plain business language — not technical explanations.
5. If the result is a dictionary or list, highlight the most important insights (e.g. totals, top items, trends).
6. If appropriate, include numbers with currency symbols, percentages, or date references.

Avoid:
- Mentioning Python or code
- Quoting raw variables
- Saying "The result is...". Just give the answer directly.

Example Input:
- Question: "What were my top 3 customers by sales in Q1?"
- Result: { "Contoso Ltd": 10500.00, "Northwind": 9500.00, "Fabrikam": 8750.00 }

Example Output:
Your top customers in Q1 were Contoso Ltd ($10,500), Northwind ($9,500), and Fabrikam ($8,750).

Always respond in a natural, friendly tone as if you''re helping a finance or operations professional.');
    end;

    local procedure FormatSummaryInput(UserQuestion: Text; ExecutionResult: Text): Text
    var
        InputBuilder: TextBuilder;
    begin
        InputBuilder.AppendLine('<question>');
        InputBuilder.AppendLine(UserQuestion);
        InputBuilder.AppendLine('</question>');
        InputBuilder.AppendLine('<result>');
        InputBuilder.AppendLine(ExecutionResult);
        InputBuilder.AppendLine('</result>');

        exit(InputBuilder.ToText());
    end;
}
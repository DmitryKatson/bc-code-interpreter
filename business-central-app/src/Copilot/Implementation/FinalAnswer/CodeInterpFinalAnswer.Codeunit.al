codeunit 50106 "GPT Code Interp Final Answer"
{
    Access = Internal;

    procedure GenerateSummary(UserQuestion: Text; ExecutionResult: Text; var AzureOpenAI: Codeunit "Azure OpenAi") Result: Text
    var
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        UIHelper: Codeunit "GPT Code Interp UI Helper";
    begin
        UIHelper.ShowStatus('Generating final answer...');

        // Set slightly higher temperature for more natural language responses
        AOAIChatCompletionParams.SetTemperature(0.7);

        // Add system and context messages
        AOAIChatMessages.AddSystemMessage(GetSystemPrompt());
        AOAIChatMessages.AddUserMessage(FormatSummaryInput(UserQuestion, ExecutionResult));

        // Generate completion
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);

        UIHelper.CloseStatus();

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

IMPORTANT: Focus ONLY on generating the TEXT part of the answer. Any charts or visualizations in the data will be displayed separately - you do NOT need to describe or reference them.

Format guidelines:
- Use basic HTML formatting tags like <b>, <i>, <br>, <ul>, <li> for better readability
- Format numbers with commas for thousands: 1,234.56
- Include currency symbols when appropriate: $1,234.56
- Structure longer answers with paragraphs separated by <br> tags

Avoid:
- Mentioning Python or code
- Quoting raw variables
- Saying "The result is...". Just give the answer directly.
- Describing charts or images (they will be shown separately)
- Using complex HTML or CSS (stick to basic formatting tags)
- Adding <html>, <body>, or <img> tags

Example Input:
- Question: "What were my top 3 customers by sales in Q1?"
- Result: { "Contoso Ltd": 10500.00, "Northwind": 9500.00, "Fabrikam": 8750.00 }

Example Output:
Your top customers in Q1 were <b>Contoso Ltd</b> ($10,500), <b>Northwind</b> ($9,500), and <b>Fabrikam</b> ($8,750).

Always respond in a natural, friendly tone as if you''re helping a finance or operations professional.
');
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
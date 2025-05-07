pageextension 50100 "GPT Code Interpreter Setup" extends "GPT Code Interpreter Setup"
{
    actions
    {
        addlast(Promoted)
        {
            actionref(AskDataInsightsCopilot_Promoted; "GPT AskDataInsightsCopilot")
            {
            }
        }
        addlast(Prompting)
        {
            action("GPT AskDataInsightsCopilot")
            {
                Caption = 'Ask Data Insights Copilot';
                Image = Sparkle;
                RunObject = page "GPT Data Insights Copilot";
                ApplicationArea = All;
            }
        }
    }
}

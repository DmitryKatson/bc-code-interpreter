pageextension 50101 "GPT Business Manager RC Ext" extends "Business Manager Role Center"
{
    actions
    {
        addlast(embedding)
        {
            action("GPT Data Insights Copilot")
            {
                Caption = 'Data Insights Copilot';
                ToolTip = 'Access Data Insights Copilot to ask data questions in natural language. The system uses AI to generate Python code, execute it securely, and provide human-friendly answers with visualizations.';
                ApplicationArea = All;
                RunObject = page "GPT Data Insights Copilot";
            }
        }
    }
}

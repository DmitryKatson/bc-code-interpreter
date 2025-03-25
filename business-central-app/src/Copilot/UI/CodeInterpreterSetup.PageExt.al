pageextension 50100 "GPT Code Interpreter Setup" extends "GPT Code Interpreter Setup"
{
    actions
    {
        addlast(Promoted)
        {
            actionref(AskCodeInterpreter_Promoted; "GPT AskCodeInterpreter")
            {
            }
        }
        addlast(Prompting)
        {
            action("GPT AskCodeInterpreter")
            {
                Caption = 'Ask Code Interpreter';
                Image = Sparkle;
                RunObject = page "GPT Code Interp Dialog";
                ApplicationArea = All;
            }
        }
    }
}

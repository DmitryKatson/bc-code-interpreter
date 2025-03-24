page 50101 "GPT Code Interp Dialog"
{
    Caption = 'Ask Code Interpreter';
    PageType = PromptDialog;
    IsPreview = true;
    Extensible = false;

    layout
    {
        area(Prompt)
        {
            field(InputText; InputText)
            {
                ShowCaption = false;
                MultiLine = true;
                ApplicationArea = All;

                trigger OnValidate()
                begin
                    ResponseText := '';
                end;
            }
        }
        area(Content)
        {
            field(ResponseText; ResponseText)
            {
                ShowCaption = false;
                MultiLine = true;
                ApplicationArea = All;
                Editable = false;
            }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Generate';
                ToolTip = 'Generate answer using Code Interpreter';

                trigger OnAction()
                begin
                    GenerateResponse();
                end;
            }
        }
    }

    var
        InputText: Text;
        ResponseText: Text;

    local procedure GenerateResponse()
    var
        CodeInterpreterImpl: Codeunit "GPT Code Interp Impl";
    begin
        ResponseText := CodeInterpreterImpl.GenerateAndExecuteCode(InputText);
    end;
}
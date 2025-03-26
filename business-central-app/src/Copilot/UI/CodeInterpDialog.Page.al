page 50101 "GPT Code Interp Dialog"
{
    Caption = 'Ask Code Interpreter';
    PageType = PromptDialog;
    IsPreview = true;
    Extensible = false;
    DataCaptionExpression = InputText;
    layout
    {
        area(Prompt)
        {
            field(InputText; InputText)
            {
                ShowCaption = false;
                MultiLine = true;
                ApplicationArea = All;
                InstructionalText = 'Enter your question here';

                trigger OnValidate()
                begin
                    ResponseTextInHtml := '';
                end;
            }
        }
        area(Content)
        {
            field(ResponseTextInHtml; ResponseTextInHtml)
            {
                ShowCaption = false;
                MultiLine = true;
                ApplicationArea = All;
                Editable = false;
                ExtendedDatatype = RichContent;
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
        ResponseTextInHtml: Text;

    local procedure GenerateResponse()
    var
        CodeInterpreterImpl: Codeunit "GPT Code Interp Impl";
    begin
        ResponseTextInHtml := CodeInterpreterImpl.GenerateAndExecuteCode(InputText);
    end;
}
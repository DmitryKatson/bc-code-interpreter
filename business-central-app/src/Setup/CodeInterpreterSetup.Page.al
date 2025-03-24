page 50100 "GPT Code Interpreter Setup"
{
    Caption = 'Code Interpreter Setup';
    PageType = Card;
    SourceTable = "GPT Code Interpreter Setup";
    InsertAllowed = false;
    DeleteAllowed = false;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(AzureOpenAI)
            {
                Caption = 'Azure OpenAI Settings';
                field("Azure OpenAI Endpoint"; Rec."Azure OpenAI Endpoint")
                {
                    ApplicationArea = All;
                    InstructionalText = 'Enter the Azure OpenAI endpoint URL (e.g., https://[resource].openai.azure.com/)';
                }
                field("Azure OpenAI Deployment"; Rec."Azure OpenAI Deployment")
                {
                    ApplicationArea = All;
                    InstructionalText = 'Enter the Azure OpenAI deployment name';
                }
                field(AzureOpenAIKey; AzureOpenAIKey)
                {
                    ApplicationArea = All;
                    Caption = 'Azure OpenAI API Key';
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        Rec.SetAzureOpenAIKeyToIsolatedStorage(AzureOpenAIKey);
                    end;
                }
            }
            group(AzureFunction)
            {
                Caption = 'Azure Function Settings';
                field("Azure Function URL"; Rec."Azure Function URL")
                {
                    ApplicationArea = All;
                    InstructionalText = 'Enter the Azure Function URL (e.g., https://[function-app].azurewebsites.net/api/main)';
                }
                field(AzureFunctionKey; AzureFunctionKey)
                {
                    ApplicationArea = All;
                    Caption = 'Azure Function Key';
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        Rec.SetAzureFunctionKeyToIsolatedStorage(AzureFunctionKey);
                    end;
                }
            }
        }
    }

    var
        [NonDebuggable]
        AzureOpenAIKey: Text;
        [NonDebuggable]
        AzureFunctionKey: Text;

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        AzureOpenAIKey := Rec.GetAzureOpenAIKey();
        AzureFunctionKey := Rec.GetAzureFunctionKey();
    end;
}
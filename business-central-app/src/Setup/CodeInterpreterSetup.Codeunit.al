codeunit 50100 "GPT Code Interpreter Setup"
{
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', false, false)]
    local procedure OnRegisterManualSetup(var Sender: Codeunit "Guided Experience")
    begin
        Sender.InsertManualSetup(
            'Configure Code Interpreter',
            'Configure Code Interpreter',
            'Set up Azure OpenAI and Azure Function connections for Code Interpreter',
            0, // Priority
            ObjectType::Page,
            Page::"GPT Code Interpreter Setup",
            "Manual Setup Category"::General,
            'Code Interpreter'
        );
    end;
}
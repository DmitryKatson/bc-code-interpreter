codeunit 50103 "GPT Code Interp UI Helper"
{
    Access = Public;

    procedure ShowStatus(Status: Text)
    var
        Dialog: Dialog;
    begin
        if GuiAllowed then
            Dialog.Open(Status);
    end;

    procedure CloseStatus()
    var
        Dialog: Dialog;
    begin
        if GuiAllowed then
            Dialog.Close();
    end;

}

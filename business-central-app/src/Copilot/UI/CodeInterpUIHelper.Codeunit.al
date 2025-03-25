codeunit 50103 "GPT Code Interp UI Helper"
{
    Access = Public;

    var
        StatusDialog: Dialog;

    procedure ShowStatus(Status: Text)
    var
    begin
        if GuiAllowed then
            StatusDialog.Open(Status);
    end;

    procedure CloseStatus()
    begin
        if GuiAllowed then
            StatusDialog.Close();
    end;

}

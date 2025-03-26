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

    procedure GenerateResultInHtml(FinalAnswer: Text; ChartImages: Text): Text
    var
        StringBuilder: TextBuilder;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        ImageBase64: Text;
        i: Integer;
    begin
        // Start with basic HTML
        StringBuilder.Append('<html><body>');

        // Add the final answer text directly (no conversion needed)
        StringBuilder.Append(FinalAnswer);

        // Add a break if there are images
        if (ChartImages <> '') and (ChartImages <> '[]') then begin
            if JsonArray.ReadFrom(ChartImages) then begin
                if JsonArray.Count > 0 then begin
                    StringBuilder.Append('<br><br>');

                    // Add each image with a simple inline style
                    for i := 0 to JsonArray.Count - 1 do begin
                        JsonArray.Get(i, JsonToken);
                        ImageBase64 := JsonToken.AsValue().AsText();

                        if ImageBase64 <> '' then
                            StringBuilder.Append(StrSubstNo('<img src="data:image/png;base64,%1" style="height:250px; margin-right:10px;" />', ImageBase64));
                    end;
                end;
            end;
        end;

        // Close the HTML
        StringBuilder.Append('</body></html>');

        exit(StringBuilder.ToText());
    end;
}

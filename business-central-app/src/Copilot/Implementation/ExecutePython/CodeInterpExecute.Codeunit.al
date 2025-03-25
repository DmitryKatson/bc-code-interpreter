codeunit 50105 "GPT Code Interp Execute"
{
    Access = Internal;

    var
        AzureFunctions: Codeunit "Azure Functions";
        AzureFunctionsResponse: Codeunit "Azure Functions Response";
        AzureFunctionsAuthentication: Codeunit "Azure Functions Authentication";
        IAzureFunctionsAuthentication: Interface "Azure Functions Authentication";

    procedure ExecuteCode(PythonCode: Text) Result: Text
    var
        RequestContent: JsonObject;
        ResponseText: Text;
        IsSuccessful: Boolean;
        Setup: Record "GPT Code Interpreter Setup";
    begin
        // Initialize authentication
        IAzureFunctionsAuthentication := AzureFunctionsAuthentication.CreateCodeAuth(Setup.GetAzureFunctionURL(), Setup.GetAzureFunctionKey());

        // Send POST request
        AzureFunctionsResponse := AzureFunctions.SendPostRequest(
            IAzureFunctionsAuthentication,
            BuildRequestContent(PythonCode),
            'application/json'
        );

        // Check response
        IsSuccessful := AzureFunctionsResponse.IsSuccessful();
        if not IsSuccessful then
            Error(GetErrorMessage(AzureFunctionsResponse));

        // Get response content
        AzureFunctionsResponse.GetResultAsText(ResponseText);

        // Return the response
        exit(ResponseText);
    end;

    local procedure BuildRequestContent(PythonCode: Text) Body: Text
    var
        RequestContent: JsonObject;
    begin
        RequestContent.Add('code', PythonCode);
        RequestContent.WriteTo(Body);
    end;

    local procedure GetErrorMessage(var AzureFunctionsResponse: Codeunit "Azure Functions Response") ErrorMessage: Text
    begin
        AzureFunctionsResponse.GetError(ErrorMessage);
    end;
}
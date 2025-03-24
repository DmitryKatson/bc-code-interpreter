table 50100 "GPT Code Interpreter Setup"
{
    Description = 'Setup for Code Interpreter Azure OpenAI and Function connections';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(2; "Azure OpenAI Endpoint"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Azure OpenAI Endpoint';
        }
        field(3; "Azure OpenAI Deployment"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Azure OpenAI Deployment';
        }
        field(4; "Azure OpenAI API Key"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Azure OpenAI API Key';
        }
        field(5; "Azure Function URL"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Azure Function URL';
        }
        field(6; "Azure Function Key"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Azure Function Key';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetAzureOpenAIEndpoint() Endpoint: Text[250]
    begin
        Get();
        exit("Azure OpenAI Endpoint");
    end;

    procedure GetAzureOpenAIDeployment() Deployment: Text[250]
    begin
        Get();
        exit("Azure OpenAI Deployment");
    end;

    procedure GetAzureFunctionURL() URL: Text[250]
    begin
        Get();
        exit("Azure Function URL");
    end;

    [NonDebuggable]
    procedure GetAzureOpenAIKey() APIKey: Text
    begin
        Get();
        if not IsNullGuid("Azure OpenAI API Key") then
            if not IsolatedStorage.Get("Azure OpenAI API Key", DataScope::Module, APIKey) then;
        exit(APIKey);
    end;

    [NonDebuggable]
    procedure GetAzureFunctionKey() FunctionKey: Text
    begin
        Get();
        if not IsNullGuid("Azure Function Key") then
            if not IsolatedStorage.Get("Azure Function Key", DataScope::Module, FunctionKey) then;
        exit(FunctionKey);
    end;

    [NonDebuggable]
    procedure SetAzureOpenAIKeyToIsolatedStorage(APIKey: Text)
    var
        NewKeyGuid: Guid;
    begin
        if not IsNullGuid("Azure OpenAI API Key") then
            if not IsolatedStorage.Delete("Azure OpenAI API Key", DataScope::Module) then;

        NewKeyGuid := CreateGuid();
        IsolatedStorage.Set(NewKeyGuid, APIKey, DataScope::Module);
        "Azure OpenAI API Key" := NewKeyGuid;
    end;

    [NonDebuggable]
    procedure SetAzureFunctionKeyToIsolatedStorage(FunctionKey: Text)
    var
        NewKeyGuid: Guid;
    begin
        if not IsNullGuid("Azure Function Key") then
            if not IsolatedStorage.Delete("Azure Function Key", DataScope::Module) then;

        NewKeyGuid := CreateGuid();
        IsolatedStorage.Set(NewKeyGuid, FunctionKey, DataScope::Module);
        "Azure Function Key" := NewKeyGuid;
    end;
}
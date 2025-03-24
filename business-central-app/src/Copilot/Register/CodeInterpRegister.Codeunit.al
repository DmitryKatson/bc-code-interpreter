codeunit 50101 "GPT Code Interp Register"
{
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    begin
        RegisterCapability();
    end;

    local procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        EnvironmentInformation: Codeunit "Environment Information";
        LearnMoreUrlTxt: Label 'https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-copilot-overview', Locked = true;
    begin
        if EnvironmentInformation.IsSaaS() then
            if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"GPT Code Interp Copilot") then
                CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"GPT Code Interp Copilot", LearnMoreUrlTxt);
    end;
}
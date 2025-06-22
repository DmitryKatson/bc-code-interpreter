permissionset 50100 "GPT Data Ins. Cop."
{
    Assignable = true;
    Permissions = tabledata "GPT Code Interpreter Setup" = RIMD,
        table "GPT Code Interpreter Setup" = X,
        codeunit "GPT Code Interp Error Analyzer" = X,
        codeunit "GPT Code Interp Execute" = X,
        codeunit "GPT Code Interp Final Answer" = X,
        codeunit "GPT Code Interp Impl" = X,
        codeunit "GPT Code Interp Python Gen" = X,
        codeunit "GPT Code Interp Register" = X,
        codeunit "GPT Code Interp UI Helper" = X,
        codeunit "GPT Code Interpreter Setup" = X,
        page "GPT Code Interpreter Setup" = X,
        page "GPT Data Insights Copilot" = X;
}
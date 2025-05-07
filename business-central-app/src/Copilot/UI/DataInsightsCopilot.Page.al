page 50101 "GPT Data Insights Copilot"
{
    Caption = 'Ask Data Insights Copilot';
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
                InstructionalText = 'Your data insights are waiting. Ask away!';

                trigger OnValidate()
                begin
                    ResponseTextInHtml := '';
                end;
            }
        }
        area(Content)
        {
            group(Response)
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
            group(ThinkingProcess)
            {
                Caption = 'Thinking Process';
                field(ThinkingProcessTextInHtml; ThinkingProcessTextInHtml)
                {
                    ShowCaption = false;
                    MultiLine = true;
                    ApplicationArea = All;
                    Editable = false;
                    ExtendedDatatype = RichContent;
                }
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

        area(PromptGuide)
        {
            group(DataSummaries)
            {
                Caption = 'Data Summaries';

                action(TopCustomers)
                {
                    Caption = 'Top customers by sales';
                    ApplicationArea = All;
                    ToolTip = 'Find out which customers are generating the most revenue';

                    trigger OnAction()
                    begin
                        InputText := 'What were my top 5 customers by sales in the last quarter?';
                    end;
                }

                action(OverdueInvoices)
                {
                    Caption = 'Overdue invoices total';
                    ApplicationArea = All;
                    ToolTip = 'Calculate the total amount of overdue invoices';

                    trigger OnAction()
                    begin
                        InputText := 'What is the total amount of overdue customer invoices?';
                    end;
                }

                action(ProductProfitability)
                {
                    Caption = 'Most profitable items';
                    ApplicationArea = All;
                    ToolTip = 'Identify items with the highest profit margin';

                    trigger OnAction()
                    begin
                        InputText := 'What are the 10 most profitable items based on margin percentage?';
                    end;
                }
            }

            group(Visualizations)
            {
                Caption = 'Visualizations';

                action(SalesChart)
                {
                    Caption = 'Monthly sales chart';
                    ApplicationArea = All;
                    ToolTip = 'Generate a chart showing sales by month';

                    trigger OnAction()
                    begin
                        InputText := 'Show me a chart of monthly sales for the past 12 months.';
                    end;
                }

                action(InventoryTurnover)
                {
                    Caption = 'Inventory turnover visualization';
                    ApplicationArea = All;
                    ToolTip = 'Create a visual representation of inventory turnover rates';

                    trigger OnAction()
                    begin
                        InputText := 'Create a chart showing inventory items with the highest turnover rates.';
                    end;
                }

                action(SalesByRegion)
                {
                    Caption = 'Sales by region pie chart';
                    ApplicationArea = All;
                    ToolTip = 'Generate a pie chart showing sales distribution by region';

                    trigger OnAction()
                    begin
                        InputText := 'Create a pie chart showing the distribution of sales by region.';
                    end;
                }
            }

            group(TrendAnalysis)
            {
                Caption = 'Trend Analysis';

                action(SalesTrend)
                {
                    Caption = 'Sales trend analysis';
                    ApplicationArea = All;
                    ToolTip = 'Analyze sales trends over time';

                    trigger OnAction()
                    begin
                        InputText := 'Analyze the trend of sales over the past 6 months and show in a chart.';
                    end;
                }

                action(OverdueInvoicesTrend)
                {
                    Caption = 'Overdue invoices trend';
                    ApplicationArea = All;
                    ToolTip = 'Track the trend of overdue invoices over time';

                    trigger OnAction()
                    begin
                        InputText := 'Show me the trend of overdue invoices over the past 6 months and show in a chart.';
                    end;
                }

                action(InventoryLevels)
                {
                    Caption = 'Inventory level trends';
                    ApplicationArea = All;
                    ToolTip = 'Track inventory levels over time to identify patterns';

                    trigger OnAction()
                    begin
                        InputText := 'Analyze how inventory levels have changed over the past year for our top 10 items and show in a chart.';
                    end;
                }
            }

            group(YearOverYear)
            {
                Caption = 'Year-over-Year Comparisons';

                action(MonthlySalesYoY)
                {
                    Caption = 'Monthly sales Y/Y comparison';
                    ApplicationArea = All;
                    ToolTip = 'Compare monthly sales between current and previous year';

                    trigger OnAction()
                    begin
                        InputText := 'Create a chart comparing monthly sales for this year versus last year, showing the percentage change.';
                    end;
                }

                action(QuarterlySalesYoY)
                {
                    Caption = 'Quarterly sales Y/Y comparison';
                    ApplicationArea = All;
                    ToolTip = 'Compare quarterly sales totals between years';

                    trigger OnAction()
                    begin
                        InputText := 'Show a visualization of quarterly sales totals for the past 2 years side by side.';
                    end;
                }

                action(TopCustomersYoY)
                {
                    Caption = 'Top customers growth Y/Y';
                    ApplicationArea = All;
                    ToolTip = 'Analyze how top customer sales have changed year over year';

                    trigger OnAction()
                    begin
                        InputText := 'Identify my top 10 customers and show how their sales have changed compared to the same period last year in a chart.';
                    end;
                }

                action(ProductCategoryYoY)
                {
                    Caption = 'Product category Y/Y growth';
                    ApplicationArea = All;
                    ToolTip = 'Compare sales by product category between years';

                    trigger OnAction()
                    begin
                        InputText := 'Create a visualization showing the year-over-year growth percentage for each product category.';
                    end;
                }
            }
        }
    }

    var
        InputText: Text;
        ResponseTextInHtml: Text;
        ThinkingProcessTextInHtml: Text;

    local procedure GenerateResponse()
    var
        CodeInterpreterImpl: Codeunit "GPT Code Interp Impl";
    begin
        ResponseTextInHtml := CodeInterpreterImpl.GenerateAndExecuteCode(InputText);
        ThinkingProcessTextInHtml := CodeInterpreterImpl.GetThinkingProcess();
    end;
}
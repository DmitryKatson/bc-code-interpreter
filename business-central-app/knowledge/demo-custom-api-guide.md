# Demo API Guide for Code Interpreter

This is a demonstration knowledge file showing how to document custom APIs and business rules for the Code Interpreter extension. Replace this content with your actual API documentation and business logic.

## Custom APIs

### Manufacturing Production API
- **Endpoint**: `contoso/manufacturing/v1.0/companies({companyId})/productionOrders`
- **Returns**: Production orders with detailed manufacturing data
- **Key fields**: 
  - `orderNumber` - Unique production order identifier
  - `itemNumber` - Product being manufactured
  - `plannedQuantity` - Target production quantity
  - `actualQuantity` - Completed quantity
  - `startDate` - Production start date
  - `endDate` - Production completion date
  - `status` - Order status (Planned, Released, Finished)

### Quality Assurance API
- **Endpoint**: `contoso/quality/v1.0/companies({companyId})/qualityInspections`
- **Returns**: Quality inspection results for manufactured items
- **Key fields**:
  - `inspectionId` - Unique inspection identifier
  - `orderNumber` - Related production order
  - `itemNumber` - Inspected product
  - `inspectionDate` - Date of inspection
  - `inspectorId` - Quality inspector
  - `result` - Pass/Fail status
  - `defectsFound` - Number of defects identified

### Warehouse Management API
- **Endpoint**: `contoso/warehouse/v1.0/companies({companyId})/warehouseEntries`
- **Returns**: Warehouse movement and inventory data
- **Key fields**:
  - `entryNumber` - Warehouse entry identifier
  - `itemNumber` - Product being moved
  - `locationCode` - Warehouse location
  - `quantity` - Movement quantity
  - `entryType` - Type of movement (Receipt, Shipment, Transfer)
  - `postingDate` - Date of warehouse activity

## Business Rules and Guidelines

### Data Filtering Best Practices
- Always filter production data by date ranges for performance optimization
- Use `$top=100` parameter for large datasets to limit response size
- Filter by `status` field to focus on relevant records (e.g., only "Finished" production orders)

### Data Relationships
- Link production orders to quality inspections using `orderNumber`
- Connect warehouse movements to production using `itemNumber`
- Use `postingDate` for time-based analysis and trend reporting

### Performance Considerations
- Avoid requesting full datasets without filters
- Use date ranges to limit data scope
- Leverage `$select` parameter to retrieve only needed fields
- Consider using `$orderby` for consistent data ordering

### Common Analysis Patterns
- **Production Efficiency**: Compare `plannedQuantity` vs `actualQuantity`
- **Quality Trends**: Analyze `defectsFound` over time periods
- **Inventory Flow**: Track warehouse movements by `entryType`
- **Cross-functional Analysis**: Combine production, quality, and warehouse data

## Example Queries

### Production Performance Analysis
**User Question**: "Show me production efficiency for finished orders this year"
**Endpoint**: `contoso/manufacturing/v1.0/companies({companyId})/productionOrders?$filter=status eq 'Finished' and endDate ge 2024-01-01&$select=orderNumber,itemNumber,plannedQuantity,actualQuantity,startDate,endDate`

### Quality Inspection Summary
**User Question**: "What's our quality inspection pass rate for this quarter?"
**Endpoint**: `contoso/quality/v1.0/companies({companyId})/qualityInspections?$filter=inspectionDate ge 2024-01-01&$select=inspectionId,orderNumber,itemNumber,result,defectsFound`

### Warehouse Activity Report
**User Question**: "Show me warehouse movement activity for the last month"
**Endpoint**: `contoso/warehouse/v1.0/companies({companyId})/warehouseEntries?$filter=postingDate ge 2024-01-01&$select=entryNumber,itemNumber,locationCode,quantity,entryType`

## Usage Instructions for AI

When analyzing manufacturing data:
1. Always start with date-filtered queries for performance
2. Use `orderNumber` to link production and quality data
3. Consider production efficiency metrics (planned vs actual)
4. Include quality metrics in production analysis
5. Track inventory movements related to production activities
6. Focus on actionable insights for process improvement

## Custom Business Logic

### Production Efficiency Calculation
- Efficiency = (Actual Quantity / Planned Quantity) × 100
- Target efficiency threshold: 95% or higher
- Flag orders below 90% efficiency for investigation

### Quality Metrics
- Defect rate = (Defects Found / Total Inspected) × 100
- Target defect rate: Less than 2%
- Track trends by week/month for process improvement

### Inventory Turnover
- Calculate turnover rate by item and location
- Identify slow-moving inventory (turnover < 4 times per year)
- Monitor warehouse space utilization

---

*Replace this demo content with your actual API documentation and business rules.* 
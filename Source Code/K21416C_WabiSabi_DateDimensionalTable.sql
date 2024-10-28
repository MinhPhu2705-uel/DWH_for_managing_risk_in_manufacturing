-- Create Date Dimensional Table
CREATE TABLE [dbo].[Dim_Date] (
   [DateKey] [int] NOT NULL,
   [Date] [date] NOT NULL,
   [Weekday] [tinyint] NOT NULL,
   [WeekDayName] [varchar](10) NOT NULL,
   [Month] [tinyint] NOT NULL,
   [MonthName] [varchar](10) NOT NULL,
   [Quarter] [tinyint] NOT NULL,
   [QuarterName] [varchar](6) NOT NULL,
   [Year] [int] NOT NULL,
   [FirstDateofYear] DATE NULL,
   [LastDateofYear] DATE NULL,
   [FirstDateofQuater] DATE NULL,
   [LastDateofQuater] DATE NULL,
   [FirstDateofMonth] DATE NULL,
   [LastDateofMonth] DATE NULL,
   [FirstDateofWeek] DATE NULL,
   [LastDateofWeek] DATE NULL
   PRIMARY KEY CLUSTERED ([DateKey] ASC)
   )

-- Insert date data to table Dim_Date
SET NOCOUNT ON

TRUNCATE TABLE DIM_Date

DECLARE @CurrentDate DATE = '2011-01-01'
DECLARE @EndDate DATE = '2015-12-31'

WHILE @CurrentDate < @EndDate
BEGIN
   INSERT INTO [dbo].[Dim_Date] (
      [DateKey],
	  [Date],
      [Weekday],
      [WeekDayName],
      [Month],
      [MonthName],
      [Quarter],
      [QuarterName],
      [Year],
      [FirstDateofYear],
      [LastDateofYear],
      [FirstDateofQuater],
      [LastDateofQuater],
      [FirstDateofMonth],
      [LastDateofMonth],
      [FirstDateofWeek],
      [LastDateofWeek]
      )
   SELECT DateKey = YEAR(@CurrentDate) * 10000 + MONTH(@CurrentDate) * 100 + DAY(@CurrentDate),
	  DATE = @CurrentDate,
      WEEKDAY = DATEPART(dw, @CurrentDate),
      WeekDayName = DATENAME(dw, @CurrentDate),
      [Month] = MONTH(@CurrentDate),
      [MonthName] = DATENAME(mm, @CurrentDate),
      [Quarter] = DATEPART(q, @CurrentDate),
      [QuarterName] = CASE 
         WHEN DATENAME(qq, @CurrentDate) = 1
            THEN 'First'
         WHEN DATENAME(qq, @CurrentDate) = 2
            THEN 'second'
         WHEN DATENAME(qq, @CurrentDate) = 3
            THEN 'third'
         WHEN DATENAME(qq, @CurrentDate) = 4
            THEN 'fourth'
         END,
      [Year] = YEAR(@CurrentDate),
      [FirstDateofYear] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-01-01' AS DATE),
      [LastDateofYear] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-12-31' AS DATE),
      [FirstDateofQuater] = DATEADD(qq, DATEDIFF(qq, 0, GETDATE()), 0),
      [LastDateofQuater] = DATEADD(dd, - 1, DATEADD(qq, DATEDIFF(qq, 0, GETDATE()) + 1, 0)),
      [FirstDateofMonth] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)) + '-01' AS DATE),
      [LastDateofMonth] = EOMONTH(@CurrentDate),
      [FirstDateofWeek] = DATEADD(dd, - (DATEPART(dw, @CurrentDate) - 1), @CurrentDate),
      [LastDateofWeek] = DATEADD(dd, 7 - (DATEPART(dw, @CurrentDate)), @CurrentDate)

   SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END

--Change data type of ModifiedDate from Datetime to Date
update Purchase.Fact_PurchaseOrderDetail
set ModifiedDate = CONVERT(DATE, ModifiedDate)

update Purchase.Fact_PurchaseOrderDetail
set ModifiedDate = CONVERT(DATE, ModifiedDate)

update Purchase.Fact_PurchaseOrderDetail
set ModifiedDate = CONVERT(DATE, ModifiedDate)


-- Create DateKey for fact table
alter table Production.Fact_WorkOrderRouting
add DateKey int;

alter table Purchase.Fact_PurchaseOrderDetail
add DateKey int;

--Mapping DateKey by ModifiedDate
UPDATE Production.Fact_WorkOrderRouting
SET DateKey = (SELECT DateKey FROM Dim_Date WHERE Dim_Date.Date = Fact_WorkOrderRouting.ModifiedDate)

UPDATE Purchase.Fact_PurchaseOrderDetail
SET DateKey = (SELECT DateKey FROM Dim_Date WHERE Dim_Date.Date = Fact_PurchaseOrderDetail.ModifiedDate)



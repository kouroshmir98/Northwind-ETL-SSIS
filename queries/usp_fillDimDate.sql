USE NorthwindDW
GO
CREATE OR ALTER PROC usp_fillDimDate(@StartDate date , @CutoffDate date)
AS 
BEGIN

	DECLARE @DateDiff int;

	select @DateDiff = DATEDIFF(day , @StartDate , @CutoffDate);

	with cteDeltaDays 
	as
	(
		SELECT 
			value 
		FROM GENERATE_SERIES(0, @DateDiff)
	),
	standardDateTable as(
	select 
		DATEADD(DAY , value , @StartDate) as standardDate
	from cteDeltaDays
	),
	baseCalandar as (
	select 
		cast(FORMAT(standardDate , 'yyyyMMdd') as int) as dateKey,
		standardDate as fullDate,
		cast(FORMAT(standardDate , 'yyyy') as int) as yearKey ,
		cast(FORMAT(standardDate , 'MM') as int) as monthKey ,
		FORMAT(standardDate , 'MMM') as  monthNameShort ,
		FORMAT(standardDate , 'MMMM') as  monthNameFull ,
		cast(FORMAT(standardDate , 'dd') as int) as monthDayKey ,
		FORMAT(standardDate , 'ddd') as weekDayNameShort ,
		FORMAT(standardDate , 'dddd') as weekDayNameFull ,
		DATEPART(QUARTER , standardDate) as quarterKey,
		case DATEPART(QUARTER , standardDate)
		when 1 then 'winter'
		when 2 then 'spring'
		when 3  then 'summer'
		when 4 then 'autumn'
		end as seasonName,
		case 
			when (DATEPART(QUARTER , standardDate) = 1 or  DATEPART(QUARTER , standardDate) = 2) then 1
			else 2
		end as yearHalfKey,
		FORMAT(standardDate , 'yyyy-MMM') as yearMonthName ,
		FORMAT(standardDate , 'yyyy-MM-dd' , 'FA') as persianFullDate ,
		cast (FORMAT(standardDate , 'yyyy' , 'FA') as int) as persianYearKey ,
		cast (FORMAT(standardDate , 'MM' , 'FA') as int) as persianMonthKey ,
		FORMAT(standardDate , 'MMMM' , 'FA') as  PersianMonthName ,
		cast(FORMAT(standardDate , 'dd' , 'FA') as int) as persianMonthDayKey ,
		FORMAT(standardDate , 'dddd' , 'FA') as persianWeekDayName ,
		case 
			when (FORMAT(standardDate , 'MM' , 'FA') = '01' or FORMAT(standardDate , 'MM' , 'FA') = '02' or FORMAT(standardDate , 'MM' , 'FA') = '03') then 1 
			when (FORMAT(standardDate , 'MM' , 'FA') = '04' or FORMAT(standardDate , 'MM' , 'FA') = '05' or FORMAT(standardDate , 'MM' , 'FA') = '06') then 2
			when (FORMAT(standardDate , 'MM' , 'FA') = '07' or FORMAT(standardDate , 'MM' , 'FA') = '08' or FORMAT(standardDate , 'MM' , 'FA') = '09') then 3
			else 4  
		end as persianQuarterKey,
			case 
			when (FORMAT(standardDate , 'MM' , 'FA') = '01' or FORMAT(standardDate , 'MM' , 'FA') = '02' or FORMAT(standardDate , 'MM' , 'FA') = '03') then N'بهار'   
			when (FORMAT(standardDate , 'MM' , 'FA') = '04' or FORMAT(standardDate , 'MM' , 'FA') = '05' or FORMAT(standardDate , 'MM' , 'FA') = '06') then N'تابستان' 
			when (FORMAT(standardDate , 'MM' , 'FA') = '07' or FORMAT(standardDate , 'MM' , 'FA') = '08' or FORMAT(standardDate , 'MM' , 'FA') = '09') then N'پاییز' 
			else N'زمستان'
		end as persianSeasonName , 
		case 
			when (FORMAT(standardDate , 'MM' , 'FA') = '01' or FORMAT(standardDate , 'MM' , 'FA') = '02' or FORMAT(standardDate , 'MM' , 'FA') = '03' or FORMAT(standardDate , 'MM' , 'FA') = '04' or FORMAT(standardDate , 'MM' , 'FA') = '05' or FORMAT(standardDate , 'MM' , 'FA') = '06') then 1
			else 2
		END as persianYearHalfKey,
		FORMAT(standardDate , 'yyyy-MMMM' , 'FA') as persianYearMonthName
	from standardDateTable
	),
	calandarTable AS (
	select
		dateKey,
		fullDate,
		yearKey ,
		monthKey ,
		monthNameShort ,
		monthNameFull ,
		monthDayKey ,
		weekDayNameShort ,
		weekDayNameFull ,
		quarterKey,
		seasonName,
		yearHalfKey,
		yearMonthName ,
		CAST(yearKey as nvarchar(4)) + 'Q' + CAST(quarterKey as nvarchar(1)) as yearQuarter,
		CAST(yearKey as nvarchar(4)) + '-'  + seasonName as yearSeason,
		CAST(yearKey as nvarchar(4)) + 'H' + CAST(yearHalfKey as nvarchar(1)) as yearHalf,
		persianFullDate ,
		persianYearKey ,
		persianMonthKey ,
		PersianMonthName ,
		persianMonthDayKey ,
		persianWeekDayName ,
		persianQuarterKey,
		persianSeasonName , 
		persianYearHalfKey,
		persianYearMonthName,
		CAST(persianYearKey as nvarchar(4)) + 'Q' + CAST(quarterKey as nvarchar(1)) as persianYearQuarter,
		CAST(persianYearKey as nvarchar(4)) + '-'  + persianSeasonName as persianYearSeason,
		CAST(persianYearKey as nvarchar(4)) + 'H' + CAST(persianYearHalfKey as nvarchar(1)) as persianYearHalf
	from baseCalandar
	)
	INSERT into 
		NorthwindDW..dimDate(
				dateKey ,
				fullDate ,
				yearKey ,
				monthKey ,
				monthNameShort ,
				monthNameFull ,
				monthDayKey ,
				weekDayNameShort ,
				weekDayNameFull ,
				quarterKey ,
				seasonName ,
				yearHalfKey ,
				yearMonthName ,
				yearQuarter ,
				yearSeason ,
				yearHalf ,
				persianFullDate ,
				persianYearKey ,
				persianMonthKey ,
				PersianMonthName  ,
				persianMonthDayKey  ,
				persianWeekDayName  ,
				persianQuarterKey  ,
				persianSeasonName , 
				persianYearHalfKey ,
				persianYearMonthName ,
				persianYearQuarter ,
				persianYearSeason ,
				persianYearHalf )
	SELECT
		dateKey ,
		fullDate ,
		yearKey ,
		monthKey ,
		monthNameShort ,
		monthNameFull ,
		monthDayKey ,
		weekDayNameShort ,
		weekDayNameFull ,
		quarterKey ,
		seasonName ,
		yearHalfKey ,
		yearMonthName ,
		yearQuarter ,
		yearSeason ,
		yearHalf ,
		persianFullDate ,
		persianYearKey ,
		persianMonthKey ,
		PersianMonthName  ,
		persianMonthDayKey  ,
		persianWeekDayName  ,
		persianQuarterKey  ,
		persianSeasonName , 
		persianYearHalfKey ,
		persianYearMonthName ,
		persianYearQuarter ,
		persianYearSeason ,
		persianYearHalf 
    from calandarTable
END
GO


-- BEGIN TRANSACTION
-- 	DECLARE @MinStgDate DATE , @MaxStgDate DATE , @MinDimDate DATE , @MaxDimDate DATE , @CountDimDate int , @TempDate DATE
-- 	select 
-- 		@MaxStgDate = (t.DateRec)
-- 	from (
-- 			SELECT 
-- 				max(orderDate) as DateRec
-- 			from NorthwindStg..orderStg
-- 			WHERE orderDate IS NOT NULL
-- 			UNION
-- 			SELECT 
-- 				max(requiredDate) as DateRec
-- 			from NorthwindStg..orderStg
-- 			WHERE requiredDate IS NOT NULL
-- 			UNION
-- 			SELECT 
-- 				max(shippedDate) as DateRec
-- 			from NorthwindStg..orderStg
-- 			WHERE shippedDate IS NOT NULL
-- 		) as t
	


-- 	select 
-- 		@MinStgDate = MIN(t.DateRec)
-- 	from (
-- 			SELECT 
-- 				Min(orderDate) as DateRec
-- 			from NorthwindStg..orderStg
-- 			WHERE orderDate IS NOT NULL
-- 			UNION
-- 			SELECT 
-- 				Min(requiredDate) as DateRec
-- 			from NorthwindStg..orderStg
-- 			WHERE requiredDate IS NOT NULL
-- 			UNION
-- 			SELECT 
-- 				Min(shippedDate) as DateRec
-- 			from NorthwindStg..orderStg
-- 			WHERE shippedDate IS NOT NULL
-- 	) as t
	

-- 	select
-- 		@MinDimDate =  MIN(fullDate)
-- 	from NorthwindDW..dimDate
	

-- 	select
-- 		@MaxDimDate = Max(fullDate)
-- 	from NorthwindDW..dimDate

-- 	select
-- 		@CountDimDate = COUNT(*)
-- 	from NorthwindDW..dimDate

-- 	IF @CountDimDate = 0 
-- 	BEGIN
-- 		EXECUTE usp_fillDimDate @MinStgDate , @MaxStgDate
-- 	END
		
-- 	ELSE
-- 		BEGIN
-- 			IF @MaxDimDate < @MaxStgDate
-- 			BEGIN
-- 				select @TempDate = DATEADD(DAY , 1 , @MaxDimDate)
-- 				EXECUTE usp_fillDimDate @TempDate , @MaxStgDate
-- 			END

-- 			IF @MinDimDate > @MinStgDate
-- 			BEGIN
-- 				select @TempDate = DATEADD(DAY , -1 , @MinDimDate)
-- 				EXECUTE usp_fillDimDate @MinStgDate , @TempDate
-- 			END
-- 		END
-- COMMIT;

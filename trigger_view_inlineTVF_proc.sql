-- UPDATE trigger ==> ModifiedDate aktualizálása, ha történt egy UPDATE a Product táblán + ListPrice követése
	CREATE OR ALTER TRIGGER trgProduct ON dbo.CarForSale FOR UPDATE
	AS
		IF @@NESTLEVEL = 1	-- Óvatosságból, hátha átállították a rekurzív triggert 'True'-ra
			BEGIN
				INSERT dbo.ProductLog (CarID, OldListPrice, NewListPrice, DMLAction)
				SELECT I.CarID, D.ListPrice, I.ListPrice, 'UPDATE'
				FROM inserted I
				INNER JOIN deleted D ON I.CarID = D.CarID 
				UPDATE dbo.CarForSale
				SET DataModified = SYSDATETIME()
				FROM inserted I
				INNER JOIN dbo.CarForSale P ON I.CarID = P.CarID
			END
	GO



Create OR ALTER	VIEW dbo.IncomeByManufacture AS
		Select M.ManName, SUM(P.UnitPrice) Total, Count(1) CountNo
		FROM Purchase P
		INNER JOIN CarForSale CFS on CFS.CarID = P.CarID
		INNER JOIN CarModel CM on CM.CarModelID = CFS.CarModelID
		INNER JOIN Manufacture	M on M.ManID = CM.ManID
		GROUP BY M.ManName
		
		
Create VIEW dbo.IncomeByModel AS
		Select M.ManName,CM.Modelname, Count(CM.CarModelID) CountNo, SUM(P.UnitPrice) LineTotal
		FROM Purchase P
		INNER JOIN CarForSale CFS on CFS.CarID = P.CarID
		INNER JOIN CarModel CM on CM.CarModelID = CFS.CarModelID
		INNER JOIN Manufacture M on CM.ManID = M.ManID
		GROUP BY CM.Modelname,M.ManName


Create VIEW dbo.StatByColor AS
		Select CFS.CarColor, Count(P.CarID) CountNo, SUM(P.Unitprice) LineTotal
		FROM Purchase P
		INNER JOIN CarForSale CFS on CFS.CarID = P.CarID
		GROUP BY CFS.CarColor
		
		
Create VIEW dbo.StatByFuel AS	
		Select CE.CarEngineName, Count(CE.CarEngineFuelID) CountNo, SUM(P.UnitPrice) LineTotal
		FROM Purchase P
		INNER JOIN CarForSale CFS on CFS.CarID = P.CarID
		INNER JOIN CarEngineFuel CE on CE.CarEngineFuelID = CFS.CarEngineFuelID
		GROUP BY CE.CarEngineName
		
		
Create VIEW dbo.SalesManStat AS
		SELECT CONCAT(E.LastName, + ' ', + E.FirstName) SalesManName,
		COUNT(P.CarID) SoldCarNo
		FROM	Purchase P
		INNER JOIN Employee E ON P.EmployeeID = E.EmployeeID
		GROUP BY CONCAT(E.LastName, + ' ', + E.FirstName)


Create VIEW dbo.SoldStatByModelAndColor AS
		Select CM.Modelname,CFS.CarColor, Count(P.CarID) CountNo
		FROM Purchase P
		INNER JOIN Customer C on P.CustomerID = C.CustomerID
		INNER JOIN Employee E on P.EmployeeID = E.EmployeeID
		INNER JOIN CarForSale CFS on CFS.CarID = P.CarID
		INNER JOIN CarModel CM on CM.CarModelID = CFS.CarModelID
		INNER JOIN Manufacture	M on M.ManID = CM.ManID
		GROUP BY CFS.CarColor,CM.Modelname
				
Create VIEW dbo.SoldStatByCategory AS
		Select CCT.CategoryName , Count(1) CountNo
		FROM Purchase P
		INNER JOIN CarForSale CFS on CFS.CarID = P.CarID
		INNER JOIN CarModel CM on CM.CarModelID = CFS.CarModelID
		INNER JOIN Manufacture	M on M.ManID = CM.ManID
		INNER JOIN CarCategoryType CCT on CCT.CarCategoryTypeID = CM.CarCategoryTypeID
		GROUP BY CCT.CategoryName
	
ALTER   VIEW [dbo].[VProduct] AS
SELECT MC.ManCountryID,MC.ManCountryCode,MC.ManCountryName,M.ManID,M.ManName,M.ManFullName,M.ManProfile,
M.Description ManDescription,M.Since,CM.CarModelID,CM.Modelname,CT.CarCategoryTypeID,CT.CategoryName,CFS.CarID,CFS.Description CarDescription,
CFS.CarColor,CFS.ListPrice,CFS.CostPrice,CFS.CarEngineFuelID,CFS.CarKM,CFS.LunchYear,CFS.CarPlateNO,CFS.PremiseCode,CF.FeatureName,CFS.DataCreate,CFS.DataModified
FROM	ManCountry MC
INNER JOIN Manufacture M ON M.ManCountryID = MC.ManCountryID
INNER JOIN CarModel CM ON CM.ManID = M.ManID
INNER JOIN CarCategoryType CT ON CT.CarCategoryTypeID = CM.CarCategoryTypeID
INNER JOIN CarForSale CFS ON CM.CarModelID = CFS.CarModelID
INNER JOIN ProductCarFeature PCF ON PCF.CarID = CFS.CarID
INNER JOIN CarFeature CF ON CF.CarFeatureID = PCF.CarFeatureID
GO


Create View dbo.VSoldProductForWho AS
SELECT CONCAT(C.LastName, + ' ', + C.FirstName) CustomerName, C.City,M.ManName,
CM.Modelname,CT.CategoryName, CFS.CarColor,P.UnitPrice,CE.CarEngineName,CFS.CarKM,CFS.LunchYear,CFS.CarPlateNO,CFS.PremiseCode,CFS.DataCreate,CFS.DataModified
FROM	ManCountry MC
INNER JOIN Manufacture M ON M.ManCountryID = MC.ManCountryID
INNER JOIN CarModel CM ON CM.ManID = M.ManID
INNER JOIN CarCategoryType CT ON CT.CarCategoryTypeID = CM.CarCategoryTypeID
INNER JOIN CarForSale CFS ON CM.CarModelID = CFS.CarModelID
INNER JOIN ProductCarFeature PCF ON PCF.CarID = CFS.CarID
INNER JOIN CarFeature CF ON CF.CarFeatureID = PCF.CarFeatureID
INNER JOIN Purchase P on CFS.CarID	= P.CarID
INNER JOIN Customer C ON C.CustomerID = P.CustomerID
INNER JOIN CarEngineFuel CE on CE.CarEngineFuelID = CFS.CarEngineFuelID
GO		
		

CREATE OR ALTER View [dbo].[VSoldbyEmployee] AS
SELECT CONCAT(E.LastName, + ' ', + E.FirstName) SalesManName,M.ManName,
CM.Modelname,CT.CategoryName, CFS.CarColor,P.UnitPrice,CE.CarEngineName,CFS.CarKM,CFS.LunchYear,CFS.CarPlateNO,CFS.PremiseCode,CFS.DataCreate,CFS.DataModified
FROM	ManCountry MC
INNER JOIN Manufacture M ON M.ManCountryID = MC.ManCountryID
INNER JOIN CarModel CM ON CM.ManID = M.ManID
INNER JOIN CarCategoryType CT ON CT.CarCategoryTypeID = CM.CarCategoryTypeID
INNER JOIN CarForSale CFS ON CM.CarModelID = CFS.CarModelID
INNER JOIN Purchase P on CFS.CarID	= P.CarID
INNER JOIN Employee E ON P.EmployeeID = E.EmployeeID
INNER JOIN CarEngineFuel CE on CE.CarEngineFuelID = CFS.CarEngineFuelID
GO
	
	
		Inline TVF utolso 3 eladás
	;WITH Y AS
		(SELECT P.EmployeeID, P.PaymentNO, 
			ROW_NUMBER() OVER(PARTITION BY P.EmployeeID ORDER BY P.PaymentNO DESC) Sorszám
		FROM Purchase P)
	SELECT *
	FROM Y
	WHERE Sorszám <= 3
	ORDER BY EmployeeID, Sorszám
	
	CREATE OR ALTER FUNCTION dbo.Top3Solds2 (@EmployeeID smallint, @N smallint) 
		RETURNS TABLE AS RETURN
		SELECT TOP (@N)
		P.PaymentNO, P.PurchaseDate, P.UnitPrice,P.DiscountedPrice,CONCAT(M.ManName,' ',CM.Modelname) ProductName
		FROM Purchase P
		INNER JOIN CarForSale CFS on CFS.CarID = P.CarID
		INNER JOIN CarModel CM on CFS.CarModelID = CM.CarModelID
		INNER JOIN Manufacture M on M.ManID = CM.ManID
		WHERE P.EmployeeID = @EmployeeID
		ORDER BY P.PaymentNO DESC
	GO
	DECLARE @N int = 3
	SELECT TS.PaymentNO, TS.PurchaseDate, TS.UnitPrice, TS.DiscountedPrice, TS.ProductName, E.EmployeeID
	FROM Employee E
	CROSS APPLY dbo.Top3Solds2(E.EmployeeID, @N) TS
	ORDER BY E.EmployeeID DESC
	GO
	
				
				
				
		CREATE	ALTER  PROC [dbo].[GetProduct2]
				@Color varchar(20) = NULL,
				@FuelID tinyint,
				@ModelName varchar(30) = NULL,
				@Category varchar(30) = NULL,
				@ManName varchar(30) = NULL
			AS
		IF NOT EXISTS (SELECT 1
				FROM CarForSale CFS
				INNER JOIN CarModel CM ON CFS.CarModelID = CM.CarModelID
				INNER JOIN Manufacture M ON M.ManID = CM.ManID
				INNER JOIN CarCategoryType CCT ON CCT.CarCategoryTypeID = CM.CarCategoryTypeID
				WHERE (@Color IS NULL OR CFS.CarColor = @Color) AND (@FuelID IS NULL OR CFS.CarEngineFuelID = @FuelID) AND (@ManName IS NULL OR M.ManName = @ManName)
				AND (@ModelName IS NULL OR CM.Modelname = @ModelName) AND (@Category IS NULL OR CCT.CategoryName = @Category))
				RETURN 1

		ELSE IF EXISTS
		(SELECT 1
				FROM CarForSale CFS
				INNER JOIN CarModel CM ON CFS.CarModelID = CM.CarModelID
				INNER JOIN Manufacture M ON M.ManID = CM.ManID
				INNER JOIN CarCategoryType CCT ON CCT.CarCategoryTypeID = CM.CarCategoryTypeID
				WHERE (@Color IS NULL OR CFS.CarColor = @Color) AND (@FuelID IS NULL OR CFS.CarEngineFuelID = @FuelID) AND (@ManName IS NULL OR M.ManName = @ManName)
				AND (@ModelName IS NULL OR CM.Modelname = @ModelName) AND (@Category IS NULL OR CCT.CategoryName = @Category) AND (CFS.ListPrice < 8000000) AND (CFS.CarKM < 15000))
				RETURN 2

		ELSE IF EXISTS
		(SELECT 1
				FROM CarForSale CFS
				INNER JOIN CarModel CM ON CFS.CarModelID = CM.CarModelID
				INNER JOIN Manufacture M ON M.ManID = CM.ManID
				INNER JOIN CarCategoryType CCT ON CCT.CarCategoryTypeID = CM.CarCategoryTypeID
				WHERE (@Color IS NULL OR CFS.CarColor = @Color) AND (@FuelID IS NULL OR CFS.CarEngineFuelID = @FuelID) AND (@ManName IS NULL OR M.ManName = @ManName)
				AND (@ModelName IS NULL OR CM.Modelname = @ModelName) AND (@Category IS NULL OR CCT.CategoryName = @Category) AND (CFS.ListPrice BETWEEN 8000001 AND 40000000) AND (CFS.CarKM < 15000))
				RETURN 3

		ELSE IF EXISTS
		(SELECT 1
				FROM CarForSale CFS
				INNER JOIN CarModel CM ON CFS.CarModelID = CM.CarModelID
				INNER JOIN Manufacture M ON M.ManID = CM.ManID
				INNER JOIN CarCategoryType CCT ON CCT.CarCategoryTypeID = CM.CarCategoryTypeID
				WHERE (@Color IS NULL OR CFS.CarColor = @Color) AND (@FuelID IS NULL OR CFS.CarEngineFuelID = @FuelID) AND (@ManName IS NULL OR M.ManName = @ManName)
				AND (@ModelName IS NULL OR CM.Modelname = @ModelName) AND (@Category IS NULL OR CCT.CategoryName = @Category) AND (CFS.CarKM > 15000))
				RETURN 4



 CREATE OR ALTER	PROC [dbo].[ListPriceRise]
			@ID int NULL,
			@ModelID int,
			@Description varchar(max) = NULL,
			@Color varchar(15) = NULL,
			@CostPrice money = NULL,
			@LunchYear smallint = NULL,
			@FuelID tinyint = NULL,
			@CarKM int = NULL,
			@PremiseCode tinyint = NULL,
			@CarPlateNO varchar(10) = NULL,
			@NewListPrice money
			AS
			IF @NewListPrice <= 0
				RETURN 1
		ELSE IF NOT EXISTS (SELECT 1 
							FROM CarForSale
							WHERE (@ID = CarID) AND (@ModelID IS NULL OR @ModelID = CarModelID))
				RETURN 2
		ELSE IF EXISTS 
					(SELECT 1
					FROM CarForSale
					WHERE (ListPrice > @NewListPrice))
				RETURN 3
		ELSE 
			UPDATE CarForSale
			SET ListPrice += @NewListPrice
			WHERE (@ID = CarID) AND (@ModelID IS NULL OR @ModelID = CarModelID) AND (ListPrice < @NewListPrice)


CREATE	OR ALTER   PROC [dbo].[InsertNewCar]
			@CarModelID int,
			@Description varchar(max) = NULL,
			@Color varchar(15) = NULL,
			@ListPrice money,
			@CostPrice money,
			@LunchYear smallint = NULL,
			@FuelID tinyint,
			@CarKM int = NULL,
			@PremiseCode tinyint,
			@CarPlateNO varchar(10) = NULL,
			@DataCreate datetime = NULL,
			@DataModified datetime = NULL
			AS
			IF @ListPrice IS NULL OR @ListPrice < 0
				RETURN 1
		ELSE IF @CarModelID IS NULL OR @ListPrice IS NULL OR @CostPrice IS NULL OR @FuelID IS NULL OR @PremiseCode IS NULL
				RETURN 2
		ELSE IF
			  @DataCreate <=sysdatetime()
				RETURN 3 
		ELSE
			INSERT CarForSale (CarModelID,Description,CarColor,ListPrice,CostPrice,LunchYear,CarEngineFuelID,CarKM,PremiseCode,CarPlateNO)
			VALUES (@CarModelID, @Description, @Color, @ListPrice, @CostPrice ,@LunchYear, @FuelID, @CarKM, @PremiseCode, @CarPlateNO) 
GO


CREATE OR ALTER PROC ImportCsv
	@FilePath varchar(100) = NULL,
	@TargetTable varchar(100) = NULL,
	@CODEPAGE varchar(10) = 65001,
	@FIRSTROW varchar(10) = 2,
	@FIELDTERMINATOR varchar(5) = ';',
	@ROWTERMINATOR varchar(5) = '\n'
AS
BEGIN
	SET NOCOUNT ON
	IF  OBJECT_ID(@TargetTable, 'U') IS NOT NULL
		BEGIN
		DECLARE @sql varchar(max)
		SET @sql = 'BULK INSERT '+ @TargetTable +' FROM ''' + @FilePath + '''
		WITH (
			CODEPAGE = '+@CODEPAGE + ',
			FIRSTROW = ' + @FIRSTROW + ',
			FIELDTERMINATOR = ''' + @FIELDTERMINATOR + ''',
			ROWTERMINATOR = ''' + @ROWTERMINATOR + '''
		)'
		EXEC (@sql)
		END
	ELSE
		RETURN 1
	--Nincs ilyen tábla
END
GO
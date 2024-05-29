--CLEANING DATA IN SQL QUERIES

SELECT *
FROM [PortfolioProject].[dbo].[HousingData]

--Standarize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM [PortfolioProject].[dbo].[HousingData]

UPDATE HousingData
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE HousingData
Add SaleDateConverted Date;

UPDATE HousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM [PortfolioProject].[dbo].[HousingData]


--Populate Property Address Data

SELECT PropertyAddress
FROM [PortfolioProject].[dbo].[HousingData]
WHERE PropertyAddress is NULL

SELECT *
FROM [PortfolioProject].[dbo].[HousingData]
--WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT *
FROM [PortfolioProject].[dbo].[HousingData] a
JOIN [PortfolioProject].[dbo].[HousingData] b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject].[dbo].[HousingData] a
JOIN [PortfolioProject].[dbo].[HousingData] b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject].[dbo].[HousingData] a
JOIN [PortfolioProject].[dbo].[HousingData] b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


--Breaking Out Address Into Individual Columns (Address, City, State)
--Working With PropertyAddress

SELECT PropertyAddress
FROM [PortfolioProject].[dbo].[HousingData]
--WHERE PropertyAddress is NULL


SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM [PortfolioProject].[dbo].[HousingData]


ALTER TABLE HousingData
Add PropertySplitAddress nvarchar(255);

UPDATE HousingData
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE HousingData
Add PropertySplitCity nvarchar(255);

UPDATE HousingData
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM [PortfolioProject].[dbo].[HousingData]


--Working With OwnerAddress

SELECT OwnerAddress
FROM [PortfolioProject].[dbo].[HousingData]

SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.'),3)
, PARSENAME(REPLACE(OwnerAddress,',', '.'),2)
, PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
FROM [PortfolioProject].[dbo].[HousingData]

ALTER TABLE HousingData
Add OwnerPropertySplitAddress nvarchar(255);

UPDATE HousingData
SET OwnerPropertySplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE HousingData
Add OwnerPropertySplitCity nvarchar(255);

UPDATE HousingData
SET OwnerPropertySplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE HousingData
Add OwnerPropertySplitState nvarchar(255);

UPDATE HousingData
SET OwnerPropertySplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

SELECT *
FROM [PortfolioProject].[dbo].[HousingData]

--Change Y and N to yes and No in 'Solid as Vacant' Field

SELECT DISTINCT (SoldasVacant), COUNT(SoldAsVacant)
FROM [PortfolioProject].[dbo].[HousingData]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldasVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [PortfolioProject].[dbo].[HousingData]


UPDATE HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				    UniqueID
					) row_num
FROM [PortfolioProject].[dbo].[HousingData]
--ORDER BY ParcelID
)
--DELETE 
--FROM RowNumCTE
--WHERE row_num > 1
--ORDER BY PropertyAddress

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



--Delete Unused Columns

SELECT *
FROM [PortfolioProject].[dbo].[HousingData]

ALTER TABLE [PortfolioProject].[dbo].[HousingData]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [PortfolioProject].[dbo].[HousingData]
DROP COLUMN SaleDate
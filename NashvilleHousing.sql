
----Cleaning Data in SQL Queries

--First Create a Copy of my Table

SELECT *
INTO Nashville_Housing
FROM NashvilleHousing


SELECT *
FROM Nashville_Housing


----Standarize Date Format from DateTime to Date

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Nashville_Housing

--Let add our converted SaleDate to Table Columns

ALTER TABLE Nashville_Housing
ADD SaleDateConverted Date

UPDATE Nashville_Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM Nashville_Housing


----Let Populate Property Address Data using ISNULL to handling NULL values

SELECT *
FROM Nashville_Housing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing a
JOIN Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing a
JOIN Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


----Let Breaking out PropertyAddress Column into Individual Colums (Address, City, State)

SELECT PropertyAddress
FROM Nashville_Housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM Nashville_Housing

----Let Add New Column to Our Table

ALTER TABLE Nashville_Housing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville_Housing
ADD PropertySplitCity NVARCHAR(255)

UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM Nashville_Housing


----Let Breaking out OwnerAddress Column into Individual Colums (Address, City, State)

SELECT OwnerAddress
FROM Nashville_Housing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Nashville_Housing

----Let Add New Column to Our Table

ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress nvarchar(255)

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville_Housing
ADD OwnerSplitState NVARCHAR(255)

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM Nashville_Housing


----Change Y AND N to YES AND NO in SolidASVacant FIELD COLUMN


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END
FROM Nashville_Housing

UPDATE Nashville_Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END


----Let Remove Duplicate Values Using CTE

WITH ROWNUMCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY 
		[UniqueID ]
		) Row_Num
FROM Nashville_Housing
--ORDER BY ParcelID
)
SELECT *
FROM ROWNUMCTE
WHERE Row_Num > 1
ORDER BY PropertyAddress

--Let remove Duplicate

WITH ROWNUMCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY 
		[UniqueID ]
		) Row_Num
FROM Nashville_Housing
--ORDER BY ParcelID
)
DELETE 
FROM ROWNUMCTE
WHERE Row_Num > 1
--ORDER BY PropertyAddress


--Let Delete Unused Columns

ALTER TABLE Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


SELECT *
FROM Nashville_Housing























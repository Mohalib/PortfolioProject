/*
Cleaning Data in SQL Queries
*/

SELECT SaleDate
FROM NashvillHousing
-------------------------------------------------------------------------------------------------------------------------
--Standerdize Data Format

SELECT SaleDate, CONVERT(Date, SaleDate) AS SalesDateUpdated --Convert DateTime to Date only
FROM NashvillHousing


ALTER TABLE NashvillHousing
ADD SaleDate DATETIME;

UPDATE NashvillHousing
SET SaleDate = CONVERT(Date,SaleDate)

-------------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data

SELECT *
FROM NashvillHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--Joined the table to itself because we have a duplicate Properties with the same ParcelID but different UniqueID (NOT POPULATED)

--STEP 1, THEN REPEAT AFTER STEP 2 BUT WITH REMOVING THE WHERE STATEMENT
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvillHousing A
    JOIN NashvillHousing B
    ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
--WHERE A.PropertyAddress IS NULL --To find empty address in A to fill it later from B

--STEP 2

--To replace the empty PropertyAddress
UPDATE A 
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress) --Checks if column A is null, populate it with B
FROM NashvillHousing A
    JOIN NashvillHousing B
    ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

-------------------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvillHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
--Going to the column name, 1= going to the first value, CHARINDEX to identify the deliminer and go until it, then removing the deliminer at the end 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM NashvillHousing

--We can't select 2 values from one column without creating two new columns
--SUBSTRING

ALTER TABLE NashvillHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvillHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvillHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvillHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM NashvillHousing



--OR use PraseName


SELECT OwnerAddress
FROM NashvillHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) AS Address
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) AS City
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) AS State
FROM NashvillHousing



ALTER TABLE NashvillHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvillHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvillHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvillHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvillHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvillHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

SELECT *
FROM NashvillHousing

-------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field
--I'll use Case Statement

--Show the data
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvillHousing
GROUP BY SoldAsVacant
ORDER BY 2

--Use case statement
SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvillHousing

--update your data
UPDATE NashvillHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvillHousing

-------------------------------------------------------------------------------------------------------------------------
--REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT *,
  ROW_NUMBER()OVER(
  PARTITION BY ParcelID,
               PropertyAddress,
               SalePrice,
               SaleDate,
               LegalReference
			   ORDER BY
			      UniqueID
			       ) ROW_NUM
FROM NashvillHousing
)

--SELECT *
--FROM RowNumCTE
--WHERE ROW_NUM > 1
--ORDER BY PropertyAddress

DELETE
FROM RowNumCTE
WHERE ROW_NUM >1

-------------------------------------------------------------------------------------------------------------------------
--DELETE unused columns

SELECT *
FROM NashvillHousing

ALTER TABLE NashvillHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvillHousing
DROP COLUMN SaleDate
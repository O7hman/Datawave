--IN THIS QUERY SET, WE ENGAGE IN CLEANING NASHVILLE HOUSING DATA TO GET IT READY FOR VARIOUS USE CASES

--Checking To see If there are any empty Property Address Fields
SELECT * 
FROM Portfolio..NashvilleHousing
WHERE PropertyAddress IS NULL

-- Self Joining a table to Fill Missing PropertyAddress with ones sharing the same Parcel ID
SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) Replaced
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
ON a.ParcelID = b.ParcelID AND
a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--Updating Null PropertyAddress Columns with those having the same ParcelID 
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
ON a.ParcelID = b.ParcelID AND
a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--Splitting the PropertyAddress Column into PropertyStreet and PropertyState
SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) PropertyStreet,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) PropertyState
FROM Portfolio..NashvilleHousing;

--Splitting the OwnerAddress Column into OwnerStreet and OwnerState
SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) OwnerStreet,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) OwnerState
--SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+1, LEN(OwnerAddress)) OwnerState
FROM Portfolio..NashvilleHousing;

SELECT *
FROM Portfolio..NashvilleHousing;

--Altering Table To Add A column for OwnerStreet
ALTER TABLE Portfolio..NashvilleHousing
ADD OwnerStreet NVARCHAR(50),
OwnerCity NVARCHAR(50),
OwnerState NVARCHAR(50);

--Altering Table To Add A column for PropertyStreet
ALTER TABLE Portfolio..NashvilleHousing
ADD PropertyStreet NVARCHAR(50),
PropertyState NVARCHAR(50);

--Updating Table to Populate The new added Column OwnerStreet
UPDATE Portfolio..NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1);

--Updating Table to Populate The new added Column PropertyStreet
UPDATE Portfolio..NashvilleHousing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
PropertyState = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

--Identifying Duplicates in the Table
WITH Duplicates AS(
SELECT [UniqueID ], ParcelID, SaleDate, PropertyAddress, OwnerAddress, ROW_NUMBER()
OVER (PARTITION BY ParcelID, SaleDate, PropertyAddress, OwnerAddress ORDER BY SaleDate) Drows
FROM Portfolio..NashvilleHousing)

SELECT *
FROM Duplicates
WHERE Drows > 1;

--Removing Duplicates from the Table
WITH Duplicates AS(
SELECT [UniqueID ], ParcelID, SaleDate, PropertyAddress, OwnerAddress, ROW_NUMBER()
OVER (PARTITION BY ParcelID, SaleDate, PropertyAddress, OwnerAddress ORDER BY SaleDate) Drows
FROM Portfolio..NashvilleHousing)

DELETE FROM Duplicates
WHERE Drows > 1;

--Identifying Mis entered values in the Sold As Vacanat Column
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) num
FROM Portfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY num;

--Identifying Mis entered vaulues with correct values
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END Mod
FROM Portfolio..NashvilleHousing;

--Updating Mis entered vaulues with correct values
UPDATE Portfolio..NashvilleHousing
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END;

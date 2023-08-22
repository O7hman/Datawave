SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) Replaced
FROM PortfolioProject..NashvilleHousingData a
JOIN PortfolioProject..NashvilleHousingData b
ON a.[ParcelID] = b.[ParcelID]
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData a
JOIN PortfolioProject..NashvilleHousingData b
ON a.[ParcelID] = b.[ParcelID]
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

EXEC sp_help 'PortfolioProject..NashvilleHousingData';

SELECT [UniqueID ]
FROM PortfolioProject..NashvilleHousingData;

ALTER TABLE PortfolioProject..NashvilleHousingData
ADD SplitPropertyAddress nvarchar(255),
SplitPropertyState nvarchar(255);

UPDATE PortfolioProject..NashvilleHousingData
SET SplitPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
SplitPropertyState = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) SplitPropertyAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) SplitPropertyState
FROM PortfolioProject..NashvilleHousingData;

SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM PortfolioProject..NashvilleHousingData;

ALTER TABLE PortfolioProject..NashvilleHousingData
ADD OwnerSplitAddress nvarchar(255),
OwnerSplitCity nvarchar(255),
OwnerSplitState nvarchar(255);

UPDATE PortfolioProject..NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1);

SELECT PropertyAddress, OwnerAddress, SUBSTRING(OwnerAddress, 1, LEN(OwnerAddress)-4)
FROM PortfolioProject..NashvilleHousingData
WHERE TRIM(PropertyAddress) <> SUBSTRING(OwnerAddress, 1, LEN(OwnerAddress)-4);

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' THEN 'No'
WHEN SoldAsVacant = 'Y' THEN 'Yes'
ELSE SoldAsVacant
END corrected
FROM PortfolioProject..NashvilleHousingData;

UPDATE PortfolioProject..NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
WHEN SoldAsVacant = 'Y' THEN 'Yes'
ELSE SoldAsVacant
END;

WITH Dup AS(
SELECT *, ROW_NUMBER()
OVER (
PARTITION BY
ParcelID,
LandUse,
PropertyAddress,
SaleDate,
SalePrice,
SoldAsVacant,
OwnerAddress
ORDER BY ParcelID
) rownum
FROM PortfolioProject..NashvilleHousingData
)
SELECT *
FROM Dup
WHERE rownum > 1;


WITH Dup AS(
SELECT *, ROW_NUMBER()
OVER (
PARTITION BY
ParcelID,
LandUse,
PropertyAddress,
SaleDate,
SalePrice,
SoldAsVacant,
OwnerAddress
ORDER BY ParcelID
) rownum
FROM PortfolioProject..NashvilleHousingData
)
DELETE FROM Dup
WHERE rownum > 1;

EXEC sp_rename 'dbo.NashvilleHousingData.[UniqueID ]', 'UniqueID', 'COLUMN';
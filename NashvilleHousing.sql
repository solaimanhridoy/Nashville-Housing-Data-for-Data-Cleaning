
-- Cleaning Data In SQL 

SELECT * 
FROM portfolio.dbo.NashvilleHousing;

----------------------------------------------------------------------------------------------------
-- Standardize Date Format

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

SELECT SaleDateConverted 
FROM portfolio.dbo.NashvilleHousing;

-----------------------------------------------------------------------------------------------------
-- Populate Property Address Data

SELECT * 
FROM portfolio.dbo.NashvilleHousing
-- WHERE PropertyAddress is NULL;
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio.dbo.NashvilleHousing a
JOIN portfolio.dbo.NashvilleHousing b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio.dbo.NashvilleHousing a
JOIN portfolio.dbo.NashvilleHousing b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL;

------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM portfolio.dbo.NashvilleHousing;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address, --  "-1" is used to remove the commam from the last index
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address -- "+1" is used for skipping the comma from left index
FROM portfolio.dbo.NashvilleHousing;

ALTER TABLE portfolio.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE portfolio.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE portfolio.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE portfolio.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) -- "+1" is used for skipping the comma from left index

SELECT * 
FROM portfolio.dbo.NashvilleHousing;


SELECT OwnerAddress
FROM portfolio.dbo.NashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM portfolio.dbo.NashvilleHousing;

ALTER TABLE portfolio.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE portfolio.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE portfolio.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE portfolio.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE portfolio.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE portfolio.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT *
FROM portfolio.dbo.NashvilleHousing;

---------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM portfolio.dbo.NashvilleHousing;

UPDATE portfolio.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

----------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- Show Duplicates
WITH RowNumCTE AS(
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
FROM portfolio.dbo.NashvilleHousing
)

SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

-- DELETE Duplictes

WITH RowNumCTE AS(
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
FROM portfolio.dbo.NashvilleHousing
)

DELETE 
FROM RowNumCTE
WHERE row_num > 1

----------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * 
FROM portfolio.dbo.NashvilleHousing;

ALTER TABLE portfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

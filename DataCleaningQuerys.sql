--Data used for this project to create NashvilleHousing table was downloaded from a Github repo
--Check README of this repo for more info

-- Fix SaleDate in order to remove time 
ALTER TABLE PortfolioProject..NashvilleHousing
ALTER COLUMN SaleDate date;

-- Removing nulls from PropertyAddress using ParcelID
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET a.PropertyAddress = b.PropertyAddress
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

-- Breaking out Address into Individual Columns
ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--Breaking out Owner Address into Individual Columns
ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--UPDATE PortfolioProject..NashvilleHousing
--SET SoldAsVacant = 'Yes'
--WHERE SoldAsVacant = 'Y'

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
						When SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

-- Remove Duplicates
WITH RowNumCTE as (
	Select *, 
		ROW_NUMBER() OVER (
			Partition by ParcelID,
						 PropertyAddress,
						 SalePrice,
						 SaleDate,
						 LegalReference
						 ORDER BY UniqueID
		) row_num
	FROM PortfolioProject..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Delete Unused Columns
ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
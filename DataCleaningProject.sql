/*

Cleaning Data in SQL Queries

*/

Select *
From DataCleaningProject..NashvilleHousing



-- Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From DataCleaningProject..NashvilleHousing

ALTER TABLE DataCleaningProject..NashvilleHousing
Add SaleDateConverted Date;

Update DataCleaningProject..NashvilleHousing
Set SaleDateConverted =  CONVERT(Date, SaleDate)



-- Populate Property Address Data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
From DataCleaningProject..NashvilleHousing a
JOIN DataCleaningProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaningProject..NashvilleHousing a
JOIN DataCleaningProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From DataCleaningProject.. NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) as Address
From DataCleaningProject..NashvilleHousing

ALTER TABLE DataCleaningProject..NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update DataCleaningProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 

ALTER TABLE DataCleaningProject..NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update DataCleaningProject..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))


Select OwnerAddress
From DataCleaningProject.. NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From DataCleaningProject.. NashvilleHousing

ALTER TABLE DataCleaningProject..NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update DataCleaningProject..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE DataCleaningProject..NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update DataCleaningProject..NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 

ALTER TABLE DataCleaningProject..NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update DataCleaningProject..NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From DataCleaningProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From DataCleaningProject..NashvilleHousing

UPDATE DataCleaningProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END



-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From DataCleaningProject..NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1



-- Delete Unused Colomns

Select *
From DataCleaningProject..NashvilleHousing
 
ALTER TABLE DataCleaningProject..NashvilleHousing
DROP COLUMN OwnerAddress,
			TaxDistrict,
			PropertyAddress

ALTER TABLE DataCleaningProject..NashvilleHousing
DROP COLUMN SaleDate






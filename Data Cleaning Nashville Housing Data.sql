/*

DATA CLEANING WITH SQL

*/

Select *
From PortfolioProject.dbo.NashvilleHousing


-- Standard Date Format

Select SaleDate, Convert(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)


-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing as a
JOIN PortfolioProject.dbo.NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing as a
JOIN PortfolioProject.dbo.NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking Out Address into Individual Columns (Address, City, State)

Select *
From PortfolioProject.dbo.NashvilleHousing

Select
Substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, Substring (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(225);

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(225);

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))


Select *
From PortfolioProject.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "SoldAsVAcant"

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order By 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject.dbo.NashvilleHousing



-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS row_num

From PortfolioProject.dbo.NashvilleHousing
)

--DELETE
--From RowNumCTE
--Where row_num > 1

Select *
From RowNumCTE
Where row_num >1
Order by PropertyAddress



-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN TaxDistrict, OwnerAddress, PropertyAddress, SaleDate
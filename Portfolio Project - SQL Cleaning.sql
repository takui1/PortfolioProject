/*
Cleaning Data in SQL Queries
*/

Select * 
from PortfolioProject.dbo.NashvilleHousing

Select SaleDate, Convert(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Alter TABLE NashvilleHousing
ALTER Column SaleDate date 

-- Populate Property Address Data

-- First let's check is we have NULL data to populate
Select * 
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is NULL

Select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN  PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-- Here we are going to copy Data from one column of the table to another
Update a
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN  PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

SELECT SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) as Address -- with this line, we are asking to create a new Column called Address, which start at the beginning (1), and stop 1 character before the comma (,). Charindex looks for comma position and pass it to the main formula
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address -- in a similar way, we ask to start at comma position+1, and to keep going till the end (using LEN  command)
from PortfolioProject.dbo.NashvilleHousing

--Now we create 2 new columns and fill them with the results above
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);
Update NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select * from NashvilleHousing


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

-- A faster way when we have a delimiter, is to use the PARSNAME command. Because we have commans and not dots (parsame works with dots, we need first to use replace)
-- Parsename will work with the modify OwnerAddress, and gave back the piece of string required (3, 2, 1)
SELECT 
PARSENAME(Replace(OwnerAddress,',', '.'), 3)
,PARSENAME(Replace(OwnerAddress,',', '.'), 2)
,PARSENAME(Replace(OwnerAddress,',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);
Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.'), 1)

Select *
From PortfolioProject.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field
-- First let's check for Y and N

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by Count(SoldAsVacant)


UPDATE PortfolioProject.Dbo.NashvilleHousing
SET SoldAsVacant = 'Yes' WHERE SoldAsVacant = 'Y';

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
From PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.Dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END


-- Remove Duplicates
-- this function work in the commented way:
-- ROW_Number function Over by partion, assign a unique number to identincal istances
-- when it encounter a different row, the count start from 1 again

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	Partition by ParcelID, -- in this point we are defining which columns to consider for the match
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)
Select * 
From RowNumCTE
WHERE row_num > 1 -- here we are asking to show us only the results where the counted duplicates are above 1
Order by PropertyAddress

-- with this will simple delete the duplicates

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	Partition by ParcelID, -- in this point we are defining which columns to consider for the match
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
Where row_num > 1


-- Delete unusued Columns (just to show)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

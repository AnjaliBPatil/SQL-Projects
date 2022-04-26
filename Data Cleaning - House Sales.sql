/*

Cleaning Data in SQL Queries

*/

SELECT * FROM PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate,SaleDateConverted
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,Saledate)

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
 on a.ParcelID=b.ParcelID
 AND a.UniqueID<>b.UniqueID
 Where a.PropertyAddress is null

 UPDATE a
 SET a.PropertyAddress=b.PropertyAddress
 From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
 on a.ParcelID=b.ParcelID
 AND a.UniqueID<>b.UniqueID
 Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking Out Address Into Individual Columns 

--Property Address (Address, City)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing


--Owner Address (Address, City, State)

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y And N To Yes And No In "Sold as Vacant" Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE
	 SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE
	 SoldAsVacant
	 END


--Just To Check
Select SoldAsVacant
From PortfolioProject.dbo.NashvilleHousing
WHERE SoldAsVacant IN ('Y','N')


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


--Identifying The Duplicates First

WITH RowNumCTE AS(
SELECT * ,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				  SalePrice,
				  LegalReference,
				  LandUse
				  ORDER BY UniqueID) row_num
				  
FROM PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
WHERE row_num>1
ORDER BY PropertyAddress

--Now Deleting Them

WITH RowNumCTE AS(
SELECT * ,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				  SalePrice,
				  LegalReference,
				  LandUse
				  ORDER BY UniqueID) row_num
				  
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
WHERE row_num>1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
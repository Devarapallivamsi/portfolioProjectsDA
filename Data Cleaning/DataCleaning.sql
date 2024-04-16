--View the data
SELECT * FROM portfolioProject..nashvilleHousing

--Standardize date format od 'SaleDate' column

UPDATE portfolioProject..nashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

--Populate null values in property address column

--Intermediate query
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolioProject..nashvilleHousing a
JOIN portfolioProject..nashvilleHousing b
ON 
a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolioProject..nashvilleHousing a
JOIN portfolioProject..nashvilleHousing b
ON 
a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Breaking out propertyAddress into separate columns(address,city,state)

--Intermediate query
SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM portfolioProject..nashvilleHousing 


ALTER TABLE portfolioProject..nashvilleHousing
ADD PropertyAddSplit Nvarchar(255),
	PropertyCitySplit Nvarchar(255);

UPDATE portfolioProject..nashvilleHousing
SET PropertyAddSplit = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
PropertyCitySplit = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);


--Breaking out ownerAddress into separate columns(address,city,state)

--Intermediate query
SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM portfolioProject..nashvilleHousing

ALTER TABLE portfolioProject..nashvilleHousing
ADD ownerAddSplit Nvarchar(255),
	ownerCitySplit Nvarchar(255),
	ownerAddState Nvarchar(255);


UPDATE portfolioProject..nashvilleHousing
SET ownerAddSplit = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	ownerCitySplit = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	ownerAddState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

--Change 'Yes' to 'Y' and 'No' to 'N' in "SoldAsVacant" column

SELECT DISTINCT(SoldASVacant) FROM portfolioProject..nashvilleHousing


SELECT CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END As bools
FROM portfolioProject..nashvilleHousing;

--Just assign the above case statement to modify the table
UPDATE portfolioProject..nashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Yes' THEN 'Y'
	WHEN SoldAsVacant = 'No' Then 'N'
	ELSE SoldAsVacant
	END
FROM portfolioProject..nashvilleHousing;


--Remove Duplicates
WITH dups as (
SELECT *,
		ROW_NUMBER() OVER (PARTITION BY ParcelID, 
						  PropertyAddress,
						  SalePrice,
						  SaleDate,
						  LegalReference
						  ORDER BY 
							UniqueID) AS row_num
FROM portfolioProject..nashvilleHousing)
SELECT * FROM dups WHERE row_num > 1

--Delete Unnecessary columns

ALTER TABLE portfolioProject..nashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate
		
ALTER TABLE portfolioProject..nashvilleHousing
DROP COLUMN SaleDate






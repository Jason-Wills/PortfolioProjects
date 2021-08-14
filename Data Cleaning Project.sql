/*
Cleaning Housing Data using SQL queries
*/

SELECT *
FROM PortfolioProjects..NashvilleHousing
ORDER BY ParcelID


-- Standardize the date format

SELECT SaleDate, SaleDateConverted
FROM PortfolioProjects..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


--Filling Property Address Data

SELECT ParcelID
FROM PortfolioProjects..NashvilleHousing
WHERE PropertyAddress IS NULL


SELECT a. ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	ON a.ParcelID = b. ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress IS NULL
ORDER BY a.ParcelID

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	ON a.ParcelID = b. ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


--Breaking Address into Individual Columns(Address, City, State)

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
FROM NashvilleHousing
ORDER BY ParcelID

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

SELECT OwnerAddress
FROM NashvilleHousing
ORDER BY ParcelID

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing
ORDER BY ParcelID

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID


--Change "Y" and "N" to "Yes" and "No" in "SoldAsVacant" column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProjects..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


--Removing Duplicates

WITH ROWNUMCTE AS
(
SELECT * , ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference
			 ORDER BY UniqueID
			 ) row_num
FROM NashvilleHousing
)
SELECT *
FROM ROWNUMCTE
WHERE row_num >1
--ORDER BY PropertyAddress


--Delete Unused columns

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, TaxDistrict, OwnerAddress
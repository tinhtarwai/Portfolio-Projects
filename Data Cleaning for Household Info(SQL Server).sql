/*
Cleaning Data with SQL
(Housing Information)
*/

Select *
From [Data Cleaning(Housing)].dbo.Housing


-----------------------------------------------------------------------------------------------
--Converting date format to 'SaleDate' column
----------------				

Select SaleDate, CONVERT(date, SaleDate)
From [Data Cleaning(Housing)].dbo.Housing

/* Update Housing
Set SaleDate = CONVERT(date, SaleDate)
(doesn't work)
*/

Alter table Housing
Add SaleDateConverted Date;

Update Housing
Set SaleDateConverted = CONVERT(date, SaleDate)

Select top 5 SaleDate, SaleDateConverted
From [Data Cleaning(Housing)].dbo.Housing


-----------------------------------------------------------------------------------------------
--Filling Null Values of PropertyAddress
----------------

Select top 5 *
From [Data Cleaning(Housing)].dbo.Housing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b. PropertyAddress, ISNULL(a.PropertyAddress, b. PropertyAddress)
From [Data Cleaning(Housing)].dbo.Housing a
Join [Data Cleaning(Housing)].dbo.Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Data Cleaning(Housing)].dbo.Housing a
Join [Data Cleaning(Housing)].dbo.Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-----------------------------------------------------------------------------------------------
--Breaking down 'PropertyAddress' column into 'Address' and 'City' cloumns (By using SUBSTRING)
----------------

Select top 5 PropertyAddress
From [Data Cleaning(Housing)].dbo.Housing


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From [Data Cleaning(Housing)].dbo.Housing

Alter table Housing
Add ProtertySplitAddress varchar(255)

Update Housing
Set ProtertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter table Housing
Add ProtertySplitCity varchar(255)

Update Housing
Set ProtertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select top 5 *
From [Data Cleaning(Housing)].dbo.Housing

-----------------------------------------------------------------------------------------------
--Breaking down 'OwnerAddress' column into 'Address', 'City' and 'State' cloumns (By using PARSENAME)
----------------									

Select top 5 OwnerAddress
From [Data Cleaning(Housing)].dbo.Housing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From [Data Cleaning(Housing)].dbo.Housing

Alter table Housing
Add OwnerSplitAddress varchar(255)

Update Housing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


Alter table Housing
Add OwnerSplitCity varchar(255)

Update Housing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Alter table Housing
Add OwnerSplitState varchar(255)

Update Housing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

Select top 5 *
From [Data Cleaning(Housing)].dbo.Housing


-----------------------------------------------------------------------------------------------
--Changing 'Y' and 'N' values into 'Yes' and 'No' in SoldAsVacant column
----------------

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Data Cleaning(Housing)].dbo.Housing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
END
From [Data Cleaning(Housing)].dbo.Housing

Update Housing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
				   END

Select top 5 *
From [Data Cleaning(Housing)].dbo.Housing

-----------------------------------------------------------------------------------------------
--Removing duplicate rows (By Using CTE and PARTITION BY)
----------------				

Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by UniqueID
				) row_num
From [Data Cleaning(Housing)].dbo.Housing
Order by ParcelID

WITH RowNumCTE AS
(Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by UniqueID
	)row_num
From [Data Cleaning(Housing)].dbo.Housing
)
Select *
From RowNumCTE
where row_num > 1
Order by PropertyAddress


WITH RowNumCTE AS
(Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate
			Order by UniqueID
	)row_num
From [Data Cleaning(Housing)].dbo.Housing
)
Delete 
From RowNumCTE
where row_num > 1

Select top 5 *
From Housing


-----------------------------------------------------------------------------------------------
--Removing unused columns
----------------		

Alter table Housing
Drop column OwnerAddress, PropertyAddress, Taxdistrict


-----------------------------------------------------------------------------------------------
--Selecting total number of Housing by State and City
----------------					

Select ProtertySplitCity, COUNT(OwnerName) as Total_Housing
from [Data Cleaning(Housing)].dbo.Housing
Group by ProtertySplitCity
Order by 2

Select OwnerSplitState, COUNT(OwnerName) as Total_Housing
from [Data Cleaning(Housing)].dbo.Housing
Group by OwnerSplitState
Order by 2
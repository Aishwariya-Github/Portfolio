-- QUERIES FOR PORTFOLIO PROJECT 2

select *
from PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate);

-- Populate Property Address Data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

-- A Second Way(Parsing)

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select 
parsename(replace(OwnerAddress, ',', '.') , 3),
parsename(replace(OwnerAddress, ',', '.') , 2),
parsename(replace(OwnerAddress, ',', '.') , 1),
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.') , 1)


-- Change Y and N to Yes and No in SoldAsVacant field

select distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
end

-- Remove Duplicates

select *
from PortfolioProject.dbo.NashvilleHousing

With RowNumCTE as(
select *,
row_number() over (
partition by ParcelID, PropertyAddress,
SalePrice, SaleDate, LegalReference 
order by UniqueID ) row_num
from PortfolioProject.dbo.NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1


-- Delete Unused Columns

Alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

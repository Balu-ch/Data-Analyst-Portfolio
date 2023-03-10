-- Data Cleaning and Data Modifying Project

select * from NashvilleHousingProject..NashvilleHousing


-----------------------------------------------------------------------------------------------------
/* Converting datetime Datatype To date since the time is Not Available */

--select SaleDate,CONVERT(date,SaleDate) from NashvilleHousingProject..NashvilleHousing
Alter Table NashvilleHousingProject..NashvilleHousing Alter column SaleDate date


/* Changing The null values with same property id */

select fir.PropertyAddress, fir.ParcelID, sec.PropertyAddress, sec.ParcelID, ISNULL(fir.PropertyAddress,sec.PropertyAddress)
from NashvilleHousingProject..NashvilleHousing fir
join NashvilleHousingProject..NashvilleHousing sec
on fir.ParcelID =sec.ParcelID
And fir.[UniqueID ] != sec.[UniqueID ]
where fir.PropertyAddress is null


update fir 
set fir.PropertyAddress = ISNULL(fir.PropertyAddress,sec.PropertyAddress)
from NashvilleHousingProject..NashvilleHousing fir
join NashvilleHousingProject..NashvilleHousing sec
on fir.ParcelID =sec.ParcelID
And fir.[UniqueID ] != sec.[UniqueID ]
where fir.PropertyAddress is null


-----------------------------------------------------------------------------------------------------
/* Modifying PropertyAddress */


-- Breaking out address into individual columns (Street, City).

select PropertyAddress, 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as PropertyStreet, 
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress)) as PropertyCity
from NashvilleHousingProject..NashvilleHousing


-- Making it as a transction to rollback if any mistake in Modifying.

begin tran t1
alter table NashvilleHousingProject..NashvilleHousing add PropertyStreet nvarchar(255) ,PropertyCity nvarchar(255)
commit tran t1


begin tran t2
update NashvilleHousingProject..NashvilleHousing set 
PropertyStreet = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
commit tran t2


begin tran t3
update NashvilleHousingProject..NashvilleHousing set 
PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress))
--rollback tran t3			--just for testing
commit tran t3


select PropertyAddress,PropertyStreet,PropertyCity from NashvilleHousingProject..NashvilleHousing 


-----------------------------------------------------------------------------------------------------
/* Modifyinf OwnerAddress */

Select OwnerAddress,
PARSENAME(Replace(OwnerAddress,',','.'),3)as OwnerStreet,
PARSENAME(Replace(OwnerAddress,',','.'),2)as OwnerCity,
PARSENAME(Replace(OwnerAddress,',','.'),1)as OwnerStates 
from NashvilleHousingProject..NashvilleHousing
where OwnerAddress is not null

begin tran t4
alter table NashvilleHousingProject..NashvilleHousing 
add OwnerStreet nvarchar(255),OwnerCity nvarchar(255),OwnerState nvarchar(255)
Commit Tran t4


select * from NashvilleHousingProject..NashvilleHousing 


--Trimming to avoid Spaces
--Just comparing the len
--select len(ltrim(PARSENAME(Replace(OwnerAddress,',','.'),2))),len(PARSENAME(Replace(OwnerAddress,',','.'),2)) 
--from NashvilleHousingProject..NashvilleHousing

begin tran t5
update NashvilleHousingProject..NashvilleHousing
set  OwnerStreet = ltrim(PARSENAME(Replace(OwnerAddress,',','.'),3)),
OwnerCity = ltrim(PARSENAME(Replace(OwnerAddress,',','.'),2)),
OwnerState = ltrim(PARSENAME(Replace(OwnerAddress,',','.'),1))
Commit tran t5


-----------------------------------------------------------------------------------------------------
/* Modifying SoldAsVacant column*/

select Distinct(SoldAsVacant),count(SoldAsVacant)
from NashvilleHousingProject..NashvilleHousing
group by SoldAsVacant
order by SoldAsVacant

select SoldAsVacant ,
case 
	when  SoldAsVacant ='N' then 'No'
	when SoldAsVacant ='Y' then 'Yes'
	else SoldAsVacant
end
from NashvilleHousingProject..NashvilleHousing

  
Begin tran t6
update NashvilleHousingProject..NashvilleHousing 
set SoldAsVacant = case 
	when  SoldAsVacant ='N' then 'No'
	when SoldAsVacant ='Y' then 'Yes'
	else SoldAsVacant 
	end
Commit tran t6

-----------------------------------------------------------------------------------------------------
/* Removing Duplicates */

select Distinct([UniqueID ]),count([UniqueID ]) 
from NashvilleHousingProject..NashvilleHousing
group by [UniqueID ]
order by count([UniqueID ]) desc

--since it is  an Unique id there will be no Duplicates but sometimes the data can be same with different unique ids.
-- using it as CTE will let you use WHERE 

With RowNumCTE as(
select *,
	ROW_NUMBER() over( 
	partition by ParcelID,
				 PropertyAddress,
				 Saledate,
				 SalePrice,
				 LegalReference
				 Order by UniqueID) row_num
from NashvilleHousingProject..NashvilleHousing
--order by parcelId
)

select * from RowNumCTE where row_num >1 order by PropertyAddress		--Checking duplicates

--Delete  from RowNumCTE where row_num >1		--Deleting duplicates


-----------------------------------------------------------------------------------------------------
/* Deleting Unused Colomns */

begin tran t7
Alter table NashvilleHousingProject..NashvilleHousing
Drop column PropertyAddress,OwnerAddress,TaxDistrict
commit tran t7

Select * from NashvilleHousingProject..NashvilleHousing


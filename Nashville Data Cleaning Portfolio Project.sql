/*
DATA CLEANING QUERIES WITH SQL
*/

select *
from [Portfolio Project].dbo.[Nashville Housing DC]

--Standardized Date format

select SaleDateConverted, convert (Date, SaleDate) as date
from [Portfolio Project].dbo.[Nashville Housing DC]

--update SaleDate table with date

alter table [Nashville Housing DC] --using alter table command to alter the table
add SaleDateConverted Date  --adding a new date column named as SaleDateConverted

update [Nashville Housing DC] --to update the newly altered column
set SaleDateConverted = convert (Date, SaleDate) --convert the actual date column ie, saledate into DATE format and set the values in the newly altered column


--Populate Property Address data
--now first we will check the property address data which is repeated and then filter out the one's with null values and then replace the null values with property address, let see how

select *
from [Portfolio Project].dbo.[Nashville Housing DC]
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress) --if a.propertyadd is null then replace with b.propertyadd
from [Portfolio Project].dbo.[Nashville Housing DC] a --self join 
join [Portfolio Project].dbo.[Nashville Housing DC] b
on a.ParcelID = b.ParcelID  --matching parcel id means matching proprtyadd
and a.[UniqueID ] <> b.[UniqueID ] --and unique id is unique
where a.PropertyAddress is null --only using for those rows where property add is null

--now we can see null values in propertyadd is getting replaced with their original add but we are still left to update it in the table

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from [Portfolio Project].dbo.[Nashville Housing DC] a --self join 
join [Portfolio Project].dbo.[Nashville Housing DC] b
on a.ParcelID = b.ParcelID  --matching parcel id means matching proprtyadd
and a.[UniqueID ] <> b.[UniqueID ] --and unique id is unique
where a.PropertyAddress is null


--Breaking out address into individual columns (address, city, state)


select PropertyAddress --what this column exactly looks like
from [Portfolio Project].dbo.[Nashville Housing DC]
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(propertyAddress, 1 , CHARINDEX(',' , propertyAddress )-1) as address, 
SUBSTRING(propertyAddress, CHARINDEX(',' , propertyAddress ) +1 , len(PropertyAddress)) as address
from [Portfolio Project].dbo.[Nashville Housing DC]

--now we'll alter the table and update the field

alter table [Portfolio Project].dbo.[Nashville Housing DC] 
add PropertysplitAddress nvarchar(255) ;

update [Portfolio Project].dbo.[Nashville Housing DC] 
set PropertysplitAddress = SUBSTRING(propertyAddress, 1 , CHARINDEX(',' , propertyAddress )-1)

alter table [Portfolio Project].dbo.[Nashville Housing DC] 
add PropertysplitCity nvarchar(255) ;

update [Portfolio Project].dbo.[Nashville Housing DC] 
set PropertysplitCity = SUBSTRING(propertyAddress, CHARINDEX(',' , propertyAddress ) +1 , len(PropertyAddress))

select *
from [Portfolio Project].dbo.[Nashville Housing DC] 

---we have one more address column ie, owner address and we have an alternative method to break the address into (add, city, state)
---Method is called as "ParseName" but this method takes period as a delimiter and delimiter for this column is comma.
--In that case, first we will replace comma with period using "Replace" and then we will apply the Parse Name.
--Now, let's write the query step by step.

select OwnerAddress
from [Portfolio Project].dbo.[Nashville Housing DC] 

select 
Parsename(replace(OwnerAddress, ',' , '.'), 3), --we have reversed the numbers since the output was getting reveresed like state, city, add
Parsename(replace(OwnerAddress, ',' , '.'), 2),
Parsename(replace(OwnerAddress, ',' , '.'), 1)
from [Portfolio Project].dbo.[Nashville Housing DC] 

--now, changes can be seen in the output, let's alter the table and update the newly added data

alter table [Portfolio Project].dbo.[Nashville Housing DC] 
add OwnersplitAddress nvarchar(255) ;

update [Portfolio Project].dbo.[Nashville Housing DC] 
set OwnersplitAddress = Parsename(replace(OwnerAddress, ',' , '.'), 3)

alter table [Portfolio Project].dbo.[Nashville Housing DC] 
add OwnersplitCity nvarchar(255) ;

update [Portfolio Project].dbo.[Nashville Housing DC] 
set OwnersplitCity = Parsename(replace(OwnerAddress, ',' , '.'), 2)

alter table [Portfolio Project].dbo.[Nashville Housing DC] 
add OwnersplitState nvarchar(255) ;

update [Portfolio Project].dbo.[Nashville Housing DC] 
set OwnersplitState = Parsename(replace(OwnerAddress, ',' , '.'), 1)

select *
from [Portfolio Project].dbo.[Nashville Housing DC] 


---Change/Replace "Y" and "N" to "Yes" and "No" in soldAsVacant column
--take a look at this column first

select distinct (SoldAsVacant),
count (SoldAsVacant)
from [Portfolio Project].dbo.[Nashville Housing DC] 
group by SoldAsVacant
order by 2

--we can see Y and N in the column and that needs to be changed
--using CASE statement, it works as if else statement

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else soldAsVacant
	 END
from [Portfolio Project].dbo.[Nashville Housing DC] 

update UniqueID
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
                        when SoldAsVacant = 'N' then 'No'
	                    else soldAsVacant
	                    END

---Remove Duplicates(note: removing duplicates is not generally done with the dataset without proper consultation)
-- below query will create a new col "row num" and have values in 1,2 where 2 indicates the duplicate row
select *,
ROW_NUMBER() Over (
partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by
			 UniqueID) row_num
from [Portfolio Project].dbo.[Nashville Housing DC] 
order by ParcelID

--query below will get all the duplicate rows (2) and delete them 

with RownumCTE As (
select *,
ROW_NUMBER() Over (
partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by
			 UniqueID ) row_num
from [Portfolio Project].dbo.[Nashville Housing DC] 
)
Select *
from RownumCTE
where row_num > 1
order by PropertyAddress
 --replace select * with Delete all the duplicate rows and then again add select * to verify the delete process


 --Delete Unused columns

 select *
 from [Portfolio Project].dbo.[Nashville Housing DC] 

 Alter table [Portfolio Project].dbo.[Nashville Housing DC] 
 Drop column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate

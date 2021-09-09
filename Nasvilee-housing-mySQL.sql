
use portfolio_1;
select * from NVH;

# --------------------------- Standarize Date Format ------------------
select SaleDate,convert(SaleDate,Date) 
from NVH;

-- update NVH           
-- set SaleDate=convert(SaleDate,Date);  

Alter Table NVH
Add SaleDateConverted Date;
update NVH
set SaleDateConverted=convert(SaleDate,Date);

select SaleDateConverted,convert(SaleDate,Date)
from NVH;

select SaleDateConverted from NVH;

select * from NVH;

-- ************Populate property address data*************

select PropertyAddress from NVH;

select PropertyAddress from NVH
where PropertyAddress is Null; #check for null

/* usually we remove null values but if we check the whole table we can see thatthe corresponding values
for null rows are important that we cannot simply remove the null values */

select * from NVH
where PropertyAddress is Null; -- check the whole table where  property address is null


/*instead of removing null values we can populate address on those null values duplicate values can be used to populate address.
if a value (say parceID) has a address and a same parcelid doesnot have address i.e Null, we can populate the address 
from the duplicated parcel id.*/


select * from NVH order by ParcelID;

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from NVH a -- labelling as "a"
Join NVH b -- labelling as "b"
on a.ParcelID=b.ParcelID
and a.UniqueID <>b.UniqueID ;  -- "<>  not equal to
-- join the table to itself and return a result where parcel ids are equal but unique ids are different.

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from NVH a -- labelling as "a"
Join NVH b -- labelling as "b"
on a.ParcelID=b.ParcelID
and a.UniqueID <>b.UniqueID  
where a.PropertyAddress is null; -- check for only null

Update NVH a -- labelling as "a"
Join NVH b -- labelling as "b"
on a.ParcelID=b.ParcelID
and a.UniqueID <>b.UniqueID 
Set a.PropertyAddress=IFNULL(a.PropertyAddress,b.PropertyAddress) 
--  SQLINES DEMO *** lues on property address.If a.propertyaddress is null replace the null with b.propertyaddress.thats why we use ISNULL.
where a.PropertyAddress is null;

/*Alter Table NVH a
Join NVH b -- labelling as "b"
on a.ParcelID=b.ParcelID
and a.UniqueID <>b.UniqueID 
Set PropertyAddress=IFNULL(a.PropertyAddress,b.PropertyAddress) 
where a.PropertyAddress is null;*/

-- now agaain check for null
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from NVH a -- labelling as "a"
Join NVH b -- labelling as "b"
on a.ParcelID=b.ParcelID
and a.UniqueID <>b.UniqueID 
where a.PropertyAddress is null; 
-- there are no null values.So,the coulmn has been updated successfully.


-- *************Breaking out Property address into Individula columns(Address,City,State)**********
select PropertyAddress from NVH;

select 
SUBSTRING(PropertyAddress,1,LOCATE(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,LOCATE(',',PropertyAddress)+1,CHAR_LENGTH(RTRIM(PropertyAddress))) as City
from NVH;

Alter Table NVH
Add PropertyAddress_RoadNO Nvarchar(255);  -- ADD column 
Update NVH
Set PropertyAddress_RoadNO =SUBSTRING(PropertyAddress,1,LOCATE(',',PropertyAddress)-1);

select * from NVH;

Alter Table NVH
Add PropertyAddress_City Nvarchar(255); -- add coulumn
Update NVH
Set PropertyAddress_City =SUBSTRING(PropertyAddress,LOCATE(',',PropertyAddress)+1,CHAR_LenGTH(PropertyAddress));

select * from NVH;

-- **********************Breaking out Owner Address into individual col for address,city************
select OwnerAddress from NVH;

-- now we Alter and update table for owner address.

ALTER TABLE NVH
Add Owner_Add_Roadno  Nvarchar(255); -- add column 
update NVH
set Owner_Add_Roadno=SUBSTRING_INDEX(OwnerAddress,',',1);

ALTER TABLE NVH
Add Owner_Add_city  Nvarchar(255); -- add column
update NVH
set Owner_Add_city=SUBSTRING_INDEX(OwnerAddress,',',-2); 

-- ALTER TABLE NVH
  -- DROP COLUMN Owner_Add_city;
update NVH
set Owner_Add_city=SUBSTRING_INDEX(Owner_Add_city,',',1); -- to get the exact city address.

select * from NVH;

ALTER TABLE NVH
Add Owner_Add_State  Nvarchar(255); -- add column
update NVH
set Owner_Add_State=SUBSTRING_INDEX(OwnerAddress,',',-1); 

select Owner_Add_State from NVH;

-- *************************  Change Y and N to Yes and No in "Sold as Vacant" field****************

select soldAsVacant from NVH;
select * from NashvilleHousing;

select distinct soldAsVacant from NVH;
-- the column contains 4 distinct values (N,Yes,Y,No).we need to keep the format same.

-- now check for the distinct values
select distinct (SoldAsVacant),count(SoldAsVacant) from NVH
group by SoldAsVacant
order by 2;

-- replace the values
select SoldAsVacant,
CASE when SoldAsVacant='Y' THEN 'Yes'
		 when SoldAsVacant='N' THEN 'No'
		 ELSE SoldAsVacant
		 END 
from NVH;

--  now update the table
Update NVH
SET SoldAsVacant=CASE when SoldAsVacant='Y' THEN 'Yes'
		 when SoldAsVacant='N' THEN 'No'
		 ELSE SoldAsVacant
		 END;
SELECT SoldAsVacant FROM NVH;


-- ************************Remove Duplicates********************
-- show the duplicates rows 
SELECT UniqueID, 
    ROW_NUMBER() OVER ( 
		PARTITION BY  ParcelID,                -- partition on things should be unique to each row 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
	) AS row_num 
FROM NVH;

-- delete duplicate rows
DELETE FROM NVH  
WHERE 
	UniqueID IN (
	SELECT 
		UniqueID 
	FROM (
		SELECT 
			UniqueID,
			ROW_NUMBER() OVER (
				PARTITION BY ParcelID,                
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
	) AS row_num 
		FROM NVH
		
	) t
    WHERE row_num > 1
);

--  again check for duplicates
SELECT 
	UniqueID 
FROM (
	SELECT 
		UniqueID,
		ROW_NUMBER() OVER (
			PARTITION BY ParcelID,                
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
	) AS row_num 
		FROM NVH
		
	) t
    WHERE row_num > 1
;
-- no duplicates found.

-- ****************remove unused-unnecessary columns**************
ALTER TABLE NVH
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN  PropertyAddress, 
DROP COLUMN SaleDate;


Select * from NVH;

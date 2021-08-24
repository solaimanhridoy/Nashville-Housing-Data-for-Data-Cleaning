USE new_schema;

CREATE TABLE `Nashville_HousingData` (
  `UniqueID` varchar(10) NOT NULL,
  `ParcelID` varchar(16) DEFAULT NULL,
  `LandUse` varchar(80) DEFAULT NULL,
  `PropertyAddress` varchar(42) DEFAULT NULL,
  `SaleDate` varchar(42) DEFAULT NULL,
  `SalePrice` varchar(11) DEFAULT NULL,
  `LegalReference` varchar(17) DEFAULT NULL,
  `SoldAsVacant` varchar(50) DEFAULT NULL,
  `OwnerName` varchar(60) DEFAULT NULL,
  `OwnerAddress` varchar(46) DEFAULT NULL,
  `Acreage` varchar(20) DEFAULT NULL,
  `TaxDistrict` varchar(25) DEFAULT NULL,
  `LandValue` varchar(20) DEFAULT NULL,
  `BuildingValue` varchar(20) DEFAULT NULL,
  `TotalValue` varchar(20) DEFAULT NULL,
  `YearBuilt` varchar(20) DEFAULT NULL,
  `Bedrooms` varchar(50) DEFAULT NULL,
  `FullBath` varchar(10) DEFAULT NULL,
  `HalfBath` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`UniqueID`)
);

-- Load CSV 
LOAD DATA LOW_PRIORITY LOCAL INFILE '/home/solaiman/Documents/Nashville Housing Data for Data Cleaning.csv' REPLACE INTO TABLE `Nashville_HousingData` FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n';


SELECT SaleDate FROM Nashville_HousingData;

-- Converted
Select saleDate, CONVERT(SaleDate, Date)
From Nashville_HousingData;

UPDATE Nashville_HousingData 
SET SaleDate = CONVERT(SaleDate, Date);
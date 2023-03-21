--- Data Cleaning using SQL

use campusx;
select * from laptopdata;
select count(*) from laptopdata;

Create table laptops_backup like laptopdata;


Insert into laptops_backup
select * from laptopdata;

select * from information_schema.TABLES
where TABLE_SCHEMA='campusx'
and table_name='laptopdata';

select DATA_LENGTH/1024 from information_schema.TABLES
where TABLE_SCHEMA='campusx'
and table_name='laptopdata';


select * from laptopdata;
ALTER TABLE laptopdata DROP COLUMN `Unnamed: 0`;
select * from laptopdata;



select * from laptopdata;
Delete from laptopdata
where `index` in (select * from laptopdata
where company is null and TypeName is null and Inches is null 
and ScreenResolution is null and Cpu is null and Ram IS NULL 
and Memory is null and Gpu is null and OpSys is null and Weight is null and price is null); 

CREATE TEMPORARY TABLE temp_table AS (
  SELECT `index`
  FROM laptopdata
  WHERE company IS NULL AND TypeName IS NULL AND Inches IS NULL 
  AND ScreenResolution IS NULL AND Cpu IS NULL AND Ram IS NULL 
  AND Memory IS NULL AND Gpu IS NULL AND OpSys IS NULL AND weight IS NULL AND price IS NULL
);

DELETE FROM laptopdata
WHERE `index` IN (
  SELECT `index`
  FROM temp_table
);

select count(*) from laptopdata;

select distinct company from laptopdata;

select distinct TypeName from laptopdata;

alter table laptopdata modify column Inches DECIMAL(10,1);

SELECT replace(Ram,'GB','') from laptopdata;

set sql_safe_updates=0;

UPDATE laptopdata l1
JOIN (
  SELECT `index`, replace(Ram,'GB','') as newRam FROM laptopdata
) l2 ON l1.`index` = l2.`index`
SET l1.Ram = l2.newRam;  

UPDATE laptopdata l1
JOIN (
  SELECT `index`, replace(Ram,'Kg','') as 'weight_in_kg' FROM laptopdata
) l2 ON l1.`index` = l2.`index`
SET l1.weight = l2.weight_in_kg;  


UPDATE laptopdata l1
JOIN (
  SELECT `index`,round(price) as 'nprice' FROM laptopdata
) l2 ON l1.`index` = l2.`index`
SET l1.price = l2.nprice;  


alter table laptopdata modify column price Integer;

select DATA_LENGTH/1024 from information_schema.TABLES
where TABLE_SCHEMA='campusx'
and table_name='laptopdata';

DELETE FROM laptopdata WHERE Weight = '';
ALTER TABLE laptopdata MODIFY COLUMN Weight INT NULL;

DELETE FROM laptopdata WHERE Ram = '';
ALTER TABLE laptopdata MODIFY COLUMN Ram INT NULL;

DELETE t1 FROM laptopdata t1
INNER JOIN laptopdata t2 
WHERE t1.index < t2.index 
AND t1.company = t2.company 
AND t1.TypeName = t2.TypeName 
AND t1.Inches = t2.Inches 
AND t1.ScreenResolution = t2.ScreenResolution 
AND t1.Cpu = t2.Cpu 
AND t1.Ram = t2.Ram 
AND t1.Memory = t2.Memory 
AND t1.Gpu = t2.Gpu 
AND t1.OpSys = t2.OpSys 
AND t1.weight = t2.weight 
AND t1.price = t2.price;

select count(*) from laptopdata;

select distinct OpSys from laptopdata;
DELETE FROM laptopdata WHERE OpSys = '';
DELETE FROM laptopdata WHERE Memory = '';
DELETE FROM laptopdata WHERE price = '';
DELETE FROM laptopdata WHERE Weight = '';
DELETE FROM laptopdata WHERE GPU = '';
DELETE FROM laptopdata WHERE Ram = '';
DELETE FROM laptopdata WHERE Cpu = '';
DELETE FROM laptopdata WHERE ScreenResolution = '';


select OpSys, 
CASE
	WHEN OpSys like '%mac%' then 'macos'
    WHEN OpSys like '%windows%' then 'windows'
    When OpSys like '%linux%' then  'linux'
    when OpSys='No OS' then 'N/A'
    ELSE 'others'
end as 'OS brand'   
FROM  laptopdata;  

Update laptopdata 
set OpSys= CASE
	WHEN OpSys like '%mac%' then 'macos'
    WHEN OpSys like '%windows%' then 'windows'
    When OpSys like '%linux%' then  'linux'
    when OpSys='No OS' then 'N/A'
    ELSE 'others'
end;

select * from laptopdata; 


alter table laptopdata
add column gpu_brand varchar(255) after Gpu,
add column gpu_name varchar(255) after gpu_brand; 


update laptopdata l1
set gpu_brand=(select substring_index(Gpu,' ',1) 
               from laptopdata l2 where l2.index=l1.index);
               
CREATE TEMPORARY TABLE tmp_table
SELECT `index`, SUBSTRING_INDEX(Gpu, ' ', 1) AS gpu_brand
FROM laptopdata;

UPDATE laptopdata l1
JOIN tmp_table l2 ON l1.index = l2.index
SET l1.gpu_brand = l2.gpu_brand;

DROP TEMPORARY TABLE tmp_table;


update laptopdata l1
set gpu_name=(select replace(Gpu,gpu_brand,'')
               from laptopdata l2 where l2.`index`=l1.`index`);
               
CREATE TEMPORARY TABLE tmp_table
SELECT `index`, SUBSTRING_INDEX(Gpu, ' ', 1) AS gpu_brand, Gpu
FROM laptopdata;

UPDATE laptopdata l1
JOIN tmp_table l2 ON l1.`index` = l2.`index`
SET l1.gpu_name = REPLACE(l2.Gpu, l2.gpu_brand, '');

DROP TEMPORARY TABLE tmp_table;

alter table laptopdata drop column Gpu;
select * from laptopdata;

alter table laptopdata
add column cpu_brand varchar(255) after Cpu,
add column cpu_name varchar(255) after cpu_brand,
add column cpu_speed varchar(255) after cpu_name;  

update laptopdata l1
set cpu_brand=(select substring_index(Cpu,' ',1)
				from laptopdata l2 where l2.index=l1.index);
                
CREATE TEMPORARY TABLE tmp_table
SELECT `index`, SUBSTRING_INDEX(Cpu, ' ', 1) AS cpu_brand FROM laptopdata;
 
UPDATE laptopdata l1
JOIN tmp_table l2 ON l1.`index` = l2.`index`
SET l1.cpu_brand = l2.cpu_brand;

DROP TEMPORARY TABLE tmp_table;


CREATE TEMPORARY TABLE tmp_table
SELECT `index`, CAST(REPLACE(SUBSTRING_INDEX(Cpu, ' ', -1), 'GHz', '') AS DECIMAL(10, 2)) AS cpu_speed
FROM laptopdata;

UPDATE laptopdata l1
JOIN tmp_table l2 ON l1.`index` = l2.`index`
SET l1.cpu_brand = l2.cpu_speed;

DROP TEMPORARY TABLE tmp_table;  

alter table laptopdata drop column Cpu;

UPDATE laptopdata l1
SET cpu_brand = (SELECT SUBSTRING_INDEX(Cpu,' ',1) 
				 FROM laptopdata l2 WHERE l2.index = l1.index);

UPDATE laptopdata l1
SET cpu_speed = (SELECT CAST(REPLACE(SUBSTRING_INDEX(Cpu,' ',-1),'GHz','')
				AS DECIMAL(10,2)) FROM laptopdata l2 
                WHERE l2.index = l1.index);
 
UPDATE laptopdata l1
SET cpu_name = (SELECT
					REPLACE(REPLACE(Cpu,cpu_brand,''),SUBSTRING_INDEX(REPLACE(Cpu,cpu_brand,''),' ',-1),'')
					FROM laptopdata l2 
					WHERE l2.index = l1.index);



SELECT ScreenResolution,
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1)
FROM laptopdata;

ALTER TABLE laptopdata
ADD COLUMN resolution_width INTEGER AFTER ScreenResolution,
ADD COLUMN resolution_height INTEGER AFTER resolution_width;

SELECT * FROM laptopdata;

set sql_safe_updates=0;
UPDATE laptopdata
SET resolution_width = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
resolution_height = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1);



ALTER TABLE laptopdata
ADD COLUMN touchscreen INTEGER AFTER resolution_height;

SELECT ScreenResolution LIKE '%Touch%' FROM laptopdata;

UPDATE laptopdata
SET touchscreen = ScreenResolution LIKE '%Touch%';

SELECT * FROM laptopdata;

ALTER TABLE laptops
DROP COLUMN ScreenResolution;

SELECT * FROM laptopdata;

SELECT cpu_name,
SUBSTRING_INDEX(TRIM(cpu_name),' ',2)
FROM laptopdata;

UPDATE laptops
SET cpu_name = SUBSTRING_INDEX(TRIM(cpu_name),' ',2);

SELECT DISTINCT cpu_name FROM laptops;

SELECT Memory FROM laptopdata;

ALTER TABLE laptopdata
ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;

SELECT Memory,
CASE
	WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    WHEN Memory LIKE '%SSD%' THEN 'SSD'
    WHEN Memory LIKE '%HDD%' THEN 'HDD'
    WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END AS 'memory_type'
FROM laptopdata;

UPDATE laptopdata
SET memory_type = CASE
	WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    WHEN Memory LIKE '%SSD%' THEN 'SSD'
    WHEN Memory LIKE '%HDD%' THEN 'HDD'
    WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END;

SELECT Memory,
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') 
ELSE 0 END
FROM laptopdata;

UPDATE laptopdata
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
secondary_storage = CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END;

SELECT 
primary_storage,
	CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
	secondary_storage,
	CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 
	ELSE secondary_storage END
FROM laptopdata;

UPDATE laptopdata
SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END;

SELECT * FROM laptopdata;

ALTER TABLE laptopdata DROP COLUMN cpu_name;
ALTER TABLE laptopdata DROP COLUMN cpu_speed;
ALTER TABLE laptopdata DROP COLUMN Memory;
ALTER TABLE laptopdata DROP COLUMN ScreenResolution;


SELECT * FROM laptopdata;


select DATA_LENGTH/1024 from information_schema.TABLES
where TABLE_SCHEMA='campusx'
and table_name='laptopdata';  

--- EDA using SQL

USE campusx;

SELECT * FROM laptopdata;

--- 1.)head, tail and sample
SELECT * FROM laptopdata
ORDER BY `index` LIMIT 5;

SELECT * FROM laptopdata
ORDER BY `index` DESC LIMIT 5;

SELECT * FROM laptopdata
ORDER BY rand() LIMIT 5;

--- 2) For numerical columns 8 number summary(count,min,max,mean,std,q1,q2,q3)
--- missing values
--- outliers
--- horizontal/vertical histogram
SELECT COUNT(Price) OVER(),
MIN(price) OVER(),
MAX(price) OVER(),
AVG(price) OVER(),
STD(price) OVER(),
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY price) OVER() AS 'Q1',
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY price) OVER() AS 'Median',
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY price) OVER() AS 'Q3'
FROM laptopdata
ORDER BY `index` LIMIT 1;

-- missing value
SELECT COUNT(price)
FROM laptopdata
WHERE price IS NULL;
 


-- outliers
SELECT * FROM (SELECT *,
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY price) OVER() AS 'Q1',
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY price) OVER() AS 'Q3'
FROM laptops) t
WHERE t.price < t.Q1 - (1.5*(t.Q3 - t.Q1)) OR
t.Price > t.Q3 + (1.5*(t.Q3 - t.Q1));


SELECT t.buckets,REPEAT('*',COUNT(*)/5) 
FROM (SELECT price, 
		CASE 
			WHEN price BETWEEN 0 AND 25000 THEN '0-25K'
			WHEN price BETWEEN 25001 AND 50000 THEN '25K-50K'
			WHEN price BETWEEN 50001 AND 75000 THEN '50K-75K'
			WHEN price BETWEEN 75001 AND 100000 THEN '75K-100K'
			ELSE '>100K'
		END AS 'buckets' 
        FROM laptopdata) t 
GROUP BY t.buckets;

SELECT REVERSE(SPACE(MAX(CHAR_LENGTH(t.histogram)) - CHAR_LENGTH(t.histogram))) 
       + REPLACE(t.histogram, '|', '') AS histogram 
FROM (
	SELECT CONCAT(t.buckets, ' | ', REPEAT('*', COUNT(*)/5)) AS histogram
	FROM (
		SELECT price, 
			CASE 
				WHEN price BETWEEN 0 AND 25000 THEN '0-25K'
				WHEN price BETWEEN 25001 AND 50000 THEN '25K-50K'
				WHEN price BETWEEN 50001 AND 75000 THEN '50K-75K'
				WHEN price BETWEEN 75001 AND 100000 THEN '75K-100K'
				ELSE '>100K'
			END AS 'buckets' 
		FROM laptopdata
	) t 
	GROUP BY t.buckets
	ORDER BY t.buckets
) t
GROUP BY LENGTH(t.histogram)
ORDER BY LENGTH(t.histogram) DESC;



SELECT Company,COUNT(Company) FROM laptopdata
GROUP BY Company;


SELECT * FROM laptopdata;

SELECT Company,
SUM(CASE WHEN Touchscreen = 1 THEN 1 ELSE 0 END) AS 'Touchscreen_yes',
SUM(CASE WHEN Touchscreen = 0 THEN 1 ELSE 0 END) AS 'Touchscreen_no'
FROM laptopdata
GROUP BY Company;

SELECT DISTINCT cpu_brand FROM laptops;

SELECT Company,
SUM(CASE WHEN cpu_brand = 'Intel' THEN 1 ELSE 0 END) AS 'intel',
SUM(CASE WHEN cpu_brand = 'AMD' THEN 1 ELSE 0 END) AS 'amd',
SUM(CASE WHEN cpu_brand = 'Samsung' THEN 1 ELSE 0 END) AS 'samsung'
FROM laptopdata
GROUP BY Company; 



-- Categorical Numerical Bivariate analysis
SELECT Company,MIN(price),
MAX(price),round(AVG(price),2),Round(STD(price),2)
FROM laptopdata
GROUP BY Company;
-- Dealing with missing values

set sql_safe_updates=0;
UPDATE laptopdata
SET price = NULL
WHERE `index` IN (7,869,1148,827,865,821,1056,1043,692,1114);
SELECT * FROM laptopdata
WHERE price IS NULL; 

-- replace missing values with mean of price
UPDATE laptopdata l1
SET price = (SELECT AVG(price) FROM laptopdata l2)
WHERE price IS NULL;
-- replace missing values with mean price of corresponding company

WITH cte AS (
  SELECT Company, AVG(price) AS avg_price
  FROM laptopdata
  GROUP BY Company
)
UPDATE laptopdata l1
JOIN cte ON l1.Company = cte.Company
SET l1.price = cte.avg_price
WHERE l1.price IS NULL;

SELECT * FROM laptopdata
WHERE price IS NULL;

-- Feature Engineering
ALTER TABLE laptopdata ADD COLUMN ppi INTEGER;

UPDATE laptopdata
SET ppi = ROUND(SQRT(resolution_width*resolution_width + resolution_height*resolution_height)/Inches);

SELECT * FROM laptopdata
ORDER BY ppi DESC;

ALTER TABLE laptopdata ADD COLUMN screen_size VARCHAR(255) AFTER Inches;

UPDATE laptopdata
SET screen_size = 
CASE 
	WHEN Inches < 14.0 THEN 'small'
    WHEN Inches >= 14.0 AND Inches < 17.0 THEN 'medium'
	ELSE 'large'
END;

SELECT screen_size,AVG(price) FROM laptopdata
GROUP BY screen_size;

-- One Hot Encoding

SELECT gpu_brand,
CASE WHEN gpu_brand = 'Intel' THEN 1 ELSE 0 END AS 'intel',
CASE WHEN gpu_brand = 'AMD' THEN 1 ELSE 0 END AS 'amd',
CASE WHEN gpu_brand = 'nvidia' THEN 1 ELSE 0 END AS 'nvidia',
CASE WHEN gpu_brand = 'arm' THEN 1 ELSE 0 END AS 'arm'
FROM laptopdata;																					


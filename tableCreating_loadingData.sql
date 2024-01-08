-- Creating tables we will use
CREATE TABLE IF NOT EXISTS athlete_events (
ID INT,
Name TEXT,
Sex TEXT,
Age INT,
Height TEXT,
Weight TEXT,
Team TEXT,
NOC TEXT,
Games TEXT,
Year INT,
Season TEXT,
City TEXT,
Sport TEXT,
Event TEXT,
Medal TEXT
);

CREATE TABLE IF NOT EXISTS regions (
NOC TEXT,
region TEXT,
notes TEXT
);

-- loading our data
LOAD DATA LOCAL INFILE 'path to your local csv file'
INTO TABLE athlete_events -- table name
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

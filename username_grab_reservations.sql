-- ==========================================================================================
-- Author:    David J. Davis
-- Create date: Feb 2017
-- Description:  A student used C# to automate a form, which isn't a big deal we could block
-- it with a captcah, but he reserved a room before the hours were set which wasn't allowed.
-- This allowed us to find, save a copy for him, and remove all of his records from the database.  
-- ==========================================================================================

SELECT
  from_unixtime(createdOn, '%M %D %Y %h:%i:%s') AS createdOn,
  username,
  from_unixtime(startTime, '%M %D %Y %h:%i:%s') AS startTime,
  from_unixtime(endTime, '%M %D %Y %h:%i:%s') AS endTime,
  from_unixtime(modifiedOn, '%M %D %Y %h:%i:%s') AS modifiedOn
FROM
  reservations
WHERE
  username='someuser'
INTO OUTFILE '/var/lib/mysql/username_grab.csv'
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n';


DELETE FROM
  reservations
WHERE username='someuser';

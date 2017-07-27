-- ==========================================================================================
-- Author:    David J. Davis
-- Create date: Feb 2017
-- Description:  The following command looks at two rooms in the Potamac State Reservation system
-- and exports them into human readable chunks.  The data is turned from unix timestamps to sets
-- human readable date times.  The room ID is turned into the rooms numbers associated with
-- those ID's. The file is then exported to a CSV for easy downloading and reading. 
-- ==========================================================================================

SELECT
  CASE roomID
    WHEN '108' THEN 'Room 211'
    WHEN '109' THEN 'Room 201'
  END AS roomID,
  from_unixtime(createdOn, '%M %D %Y %h:%i %p') AS createdOn,
  createdBy,
  from_unixtime(startTime, '%M %D %Y %h:%i %p') AS startTime,
  from_unixtime(endTime, '%M %D %Y %h:%i %p') AS endTime,
  from_unixtime(modifiedOn, '%M %D %Y %h:%i:%s') AS modifiedOn,
  modifiedBy,
  username,
  initials,
  groupname,
  comments,
  openEvent,
  openEventDescription
FROM
  reservations
WHERE
  roomID IN (108, 109)
AND
  from_unixtime(startTime, '%Y%m%d') >=  '20170101'
AND
  from_unixtime(startTime, '%Y%m%d') <  '20170201'
INTO OUTFILE '/var/lib/mysql/potomac_state_database.csv'
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n';

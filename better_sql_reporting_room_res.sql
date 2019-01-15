-- All Time Query 
-- |  1 | Evansdale Library     |
-- |  2 | Downtown Library      |
-- |  3 | HSC Library           |
-- |  4 | Potomac State College |
-- |  5 | Law Library           |
SELECT
  reservations.roomID,
  rooms.number AS roomNumber,
  rooms.name AS roomName,
  from_unixtime(reservations.createdOn, '%M %D %Y %h:%i %p') AS createdOn,
  createdBy,
  from_unixtime(reservations.startTime, '%M %D %Y %h:%i %p') AS startTime,
  from_unixtime(reservations.endTime, '%M %D %Y %h:%i %p') AS endTime,
  from_unixtime(reservations.modifiedOn, '%M %D %Y %h:%i:%s') AS modifiedOn,
  modifiedBy,
  username,
  initials,
  groupname,
  comments,
  openEvent,
  openEventDescription
FROM
  reservations
LEFT JOIN rooms ON reservations.roomID = rooms.ID 
WHERE
  rooms.building=2
INTO OUTFILE '/var/lib/mysql/downtown_all.csv'
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n';

-- Time Ymd Query 
-- |  1 | Evansdale Library     |
-- |  2 | Downtown Library      |
-- |  3 | HSC Library           |
-- |  4 | Potomac State College |
-- |  5 | Law Library           |
SELECT
  reservations.roomID,
  rooms.number AS roomNumber,
  rooms.name AS roomName,
  from_unixtime(reservations.createdOn, '%M %D %Y %h:%i %p') AS createdOn,
  createdBy,
  from_unixtime(reservations.startTime, '%M %D %Y %h:%i %p') AS startTime,
  from_unixtime(reservations.endTime, '%M %D %Y %h:%i %p') AS endTime,
  from_unixtime(reservations.modifiedOn, '%M %D %Y %h:%i:%s') AS modifiedOn,
  modifiedBy,
  username,
  initials,
  groupname,
  comments,
  openEvent,
  openEventDescription
FROM
  reservations
LEFT JOIN rooms ON reservations.roomID = rooms.ID 
WHERE
  rooms.building=2
  AND
   from_unixtime(startTime, '%Y%m%d') >=  '20150101'
  AND
    from_unixtime(startTime, '%Y%m%d') <  '20190201'
INTO OUTFILE '/var/lib/mysql/downtown_all.csv'
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n';

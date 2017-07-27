UPDATE `agent_corporate_entity`
	 SET `publish`=1 WHERE `publish`=0 OR `publish` IS NULL; 

UPDATE `agent_family`
	 SET `publish`=1 WHERE `publish`=0 OR `publish` IS NULL; 

UPDATE `agent_person`
	 SET `publish`=1 WHERE `publish`=0 OR `publish` IS NULL; 

UPDATE `agent_software`
	 SET `publish`=1 WHERE `publish`=0 OR `publish` IS NULL; 


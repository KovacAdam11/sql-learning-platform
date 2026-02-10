-- 000_privileges.sql
CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY 'apppass';

-- práva na template databázu (aby vedel čítať úlohy + dataset)
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX, TRIGGER, CREATE VIEW, SHOW VIEW, EXECUTE
ON sql_training.* TO 'appuser'@'%';

-- práva na vytváranie a mazanie databáz (sandbox)
GRANT CREATE, DROP ON *.* TO 'appuser'@'%';

-- práva na všetky sandbox databázy
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX, TRIGGER, CREATE VIEW, SHOW VIEW, EXECUTE
ON `sql_sandbox\_%`.* TO 'appuser'@'%';

FLUSH PRIVILEGES;

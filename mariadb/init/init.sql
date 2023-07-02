CREATE USER 'hive'@'%' IDENTIFIED BY 'hive' password expire never;
GRANT ALL ON *.* TO 'hive'@'%';
flush privileges;

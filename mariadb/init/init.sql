CREATE USER 'hive'@'%' IDENTIFIED BY 'hive' password expire never with grant option;
GRANT ALL ON *.* TO 'hive'@'%';
flush privileges;

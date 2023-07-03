CREATE USER 'hive'@'%' IDENTIFIED BY 'hive' password expire never;
GRANT ALL ON *.* TO 'hive'@'%' IDENTIFIED BY 'hive';
FLUSH PRIVILEGES;

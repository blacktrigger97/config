CREATE USER 'root'@'%' IDENTIFIED BY 'hive' password expire never;
GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'hive';
FLUSH PRIVILEGES;

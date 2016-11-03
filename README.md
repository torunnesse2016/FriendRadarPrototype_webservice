geo_app
=====

An OTP application

Build
-----

    $ rebar3 compile



1. download & install erlange 
https://www.erlang-solutions.com/resources/download.html
2. download & install redis.io
http://redis.io/download
3. download & install mySQL

4. start mysql server

5. download & install sequel pro

6. access to local host

7. set up password

http://stackoverflow.com/questions/6474775/setting-the-mysql-root-user-password-on-os-x

8. open app.config file 
   and change password with mysql password

9. download rebar 3

copy and past rebar3 to destination directory

10. open teminal

run below command

sudo ./rebar3 shell


This is for checking redis DB status

11. set up MySQL DB

sql from dump.sql file

-------

CREATE TABLE `users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(64) DEFAULT NULL,
  `password` varchar(32) DEFAULT NULL COMMENT 'md5 -- use more strong',
  `facebookid` bigint(20) DEFAULT NULL,
  `username` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
-------



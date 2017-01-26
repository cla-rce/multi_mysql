v1.1.1 (2017-01-26)
====
* Switch to the password generating function in the newer OpenSSL cookbook

v1.1.0 (2016-01-06)
====
* Allow installation of MariaDB instead of MySQL
* Eliminate actions that caused the MySQL root password to show up in chef-client logs
* Update default MySQL version to 5.6.28

v1.0.1 (2014-01-30)
====
* Explicitly reference my.cnf file location
* Remove 'server-current' directory, leaving only 'server'

TODO
====
* Implement backups
* Implement :upgrade action for mysql_instance

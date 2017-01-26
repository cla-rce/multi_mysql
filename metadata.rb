name             'multi_mysql'
maintainer       'Peter Walz, (C) Regents of the University of Minnesota'
maintainer_email 'pnw@umn.edu'
license          'Apache 2.0'
description      'Installs/Configures multiple MySQL or MariaDB server instances'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.1.1'

depends          'ark'
depends          'openssl', '>= 4.1.0'

supports         'ubuntu', '>= 12.04'

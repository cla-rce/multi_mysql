name             'multi_mysql'
maintainer       'Adam Mielke, (C) Regents of the University of Minnesota'
maintainer_email 'adam@umn.edu'
license          'Apache 2.0'
description      'Installs/Configures multiple MySQL server instances'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.1'

depends          'openssl', '~> 1.1'
depends          'ark', '~> 0.4'

supports         'ubuntu', '>= 12.04'
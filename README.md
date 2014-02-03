# multi_mysql cookbook

Installs and manages multiple MySQL servers on a single node. Uses pre-compiled binaries from MySQL rather than OS packages.

# Requirements

Currently only tested on Ubuntu 12.04 LTS

# Usage

`include_recipe multi_mysql::default` will install MySQL 5.6.15 in /db/binaries and will set up and start a default server instance in /db/instances/default.

If you prefer to set up multiple other instances, create a new cookbook that depends on this one, and use the multi_mysql_package and multi_mysql_instance providers.

# Providers

* multi_mysql_package

* multi_mysql_instance

# Attributes

* `node['multi_mysql']['base_dir']`
* `node['multi_mysql']['default_package']['version']`
* `node['multi_mysql']['default_package']['url']`
* `node['multi_mysql']['default_package']['checksum']`

# Recipes

`default`: installs MySQL 5.6.15 in /db/binaries and sets up and starts a default server instance in /db/instances/default.

# Author

Author:: Adam Mielke, (C) Regents of the University of Minnesota (<adam@umn.edu>)

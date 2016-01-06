# multi_mysql cookbook

Installs and manages multiple MySQL or MariaDB servers on a single node. Uses pre-compiled binaries rather than OS packages.

# Requirements

Ubuntu 12.04 LTS or Ubuntu 14.04 LTS

# Usage

`include_recipe multi_mysql::default` will unpack MySQL or MariaDB to `node['multi_mysql']['base_dir']`/binaries and will set up and start a default server instance in `node['multi_mysql']['base_dir']`/instances/default.

If you need to set up additional instances, create a new cookbook that depends on this one, and use the multi_mysql_package and multi_mysql_instance providers.

# Providers

* multi_mysql_package
* multi_mysql_instance

# Attributes

* `node['multi_mysql']['base_dir']`
* `node['multi_mysql']['default_package']['distribution']`
* `node['multi_mysql']['default_package']['version']`
* `node['multi_mysql']['default_package']['url']`
* `node['multi_mysql']['default_package']['checksum']`

# Recipes

`default`: (see the Usage section above)

# Author

Author:: Adam Mielke, (C) Regents of the University of Minnesota (<adam@umn.edu>)
Author:: Peter Walz, (C) Regents of the University of Minnesota (<pnw@umn.edu>)

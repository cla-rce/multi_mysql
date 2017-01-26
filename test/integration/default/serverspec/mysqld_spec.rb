require 'spec_helper'

# dist = 'mysql'
# ver = '5.6.28'
dist = 'mariadb'
ver = '10.1.21'

describe service('mysqld_default') do
  it { should be_enabled }
  it { should be_running }
end

describe file("/db/binaries/#{dist}-#{ver}") do
  it { should be_directory }
end

describe file("/db/instances/default/server") do
  it { should be_linked_to "../../binaries/#{dist}-#{ver}" }
end

describe file("/db/instances/default/mysql.sock") do
  it { should be_owned_by "mysql" }
end

describe file("/db/instances/default/etc/my.cnf") do
  its(:content) { should match %r|^datadir = /db/instances/default/data$| }
end

describe port('3306') do
  it { should be_listening }
end

# Can't use 'show databases' here because the order of names it returns
# is not guaranteed.
describe command('mysql -S /db/instances/default/mysql.sock -u root -p"rootpass" -e "select SCHEMA_NAME from information_schema.SCHEMATA order by SCHEMA_NAME;"') do
  its(:stdout) { should match %r/SCHEMA_NAME.information_schema.mysql.performance_schema/m }
end

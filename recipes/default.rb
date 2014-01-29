#
# Cookbook Name:: cla_mysql
# Recipe:: default
#
# Copyright (C) 2014 Adam Mielke, (C) Regents of the University of Minnesota
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Set up directory structure
directory '/db'
directory '/db/dist'
directory '/db/binaries'
directory '/db/instances'
directory '/db/backups'

# MySQL binaries are linked against libaio which isn't in a base install of Ubuntu 12.04
package 'libaio1'

node['cla_mysql']['mysql_binaries'].each_pair do |version, mysql|

  ark "mysql-#{version}" do
    url mysql['url']
    checksum mysql['checksum']
    path '/db/binaries'
    action :put
  end

end

node['cla_mysql']['instances'].each_pair do |instance_name, instance|

  instance_root = "/db/instances/#{instance_name}"

  if instance['create_user']
    group instance['group'] do
      system true
    end

    user instance['user'] do
      gid instance['group']
      system true
    end
  end

  directory instance_root do
    owner instance['user']
    group instance['group']
    mode 00755
  end

  directory "#{instance_root}/data" do
    owner instance['user']
    group instance['group']
    mode 00755
  end

  directory "#{instance_root}/etc" do
    owner 'root'
    group 'root'
    mode 00755
  end

  directory "#{instance_root}/log" do
    owner instance['user']
    group instance['group']
    mode 00755
  end

  link "#{instance_root}/server-current" do
    to "../../binaries/mysql-#{instance['version']}"
  end

  directory "#{instance_root}/server" do
    owner instance['user']
    group instance['group']
    mode 00755
  end

  # Add Chef "link" resources to the run_list to generate symlink farm in "#{instance_root}/server".
  # This needs to be done dynamically at converge time because the mysql binaries may not exist yet
  # during compile time, since the resource ark[mysql-#{version}] will not have converged by then.
  ruby_block "create #{instance_root}/server symlinks" do
    block do
      Dir.glob("#{instance_root}/server-current/*").map {|f| File.basename(f)}.each do |target|
        # Below is straight Ruby equivalent to the Chef DSL code:
        #  link "#{instance_root}/server/#{target}" do
        #    to "../server-current/#{target}"
        #  end
        l = Chef::Resource::Link.new("#{instance_root}/server/#{target}", self.run_context)
        l.to("../server-current/#{target}")
        self.run_context.resource_collection.insert(l)
      end
    end
  end

  link "#{instance_root}/server/my.cnf" do
    to '../etc/my.cnf'
  end

  execute "mysql_install_db-#{instance_name}" do
    cwd "#{instance_root}/server"
    command "scripts/mysql_install_db --basedir='#{instance_root}/server' --datadir='#{instance_root}/data' --user='#{instance['user']}'"
    not_if { File.directory?("#{instance_root}/data/mysql") }
  end

  ::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
  node.set_unless['cla_mysql']['instances'][instance_name]['server_root_password'] = secure_password

  template "#{instance_root}/etc/grants.sql" do
    source 'grants.sql.erb'
    variables ({instance_root: instance_root})
    owner 'root'
    group 'root'
    mode 00600
    notifies :run, "execute[install-grants-#{instance_root}]", :immediately
  end

  execute "install-grants-#{instance_root}" do
    command "#{instance_root}/server/bin/mysql -u root"
    action :nothing
  end

  template "/etc/init.d/mysqld_#{instance_name}" do
    source 'init.mysqld.erb'
    owner 'root'
    group 'root'
    mode 00755
    variables ({
      instance_root: instance_root
      })
    notifies :restart, "service[mysqld_#{instance_name}]"
  end

  service "mysqld_#{instance_name}" do
    action [:enable, :start]
  end

end

  
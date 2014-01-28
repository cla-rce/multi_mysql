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

  ruby_block "create #{instance_root}/server symlinks" do
    block do
      Dir.glob("#{instance_root}/server-current/*").map {|f| File.basename(f)}.each do |target|
        l = Chef::Resource::Link.new("#{instance_root}/server/#{target}", self.run_context)
        l.to("../server-current/#{target}")
        self.run_context.resource_collection.insert(l)
      end
    end
  end

end

  
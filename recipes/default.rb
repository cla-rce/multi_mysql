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
%w(binaries instances backups).each do |subdir|
  directory "#{node['cla_mysql']['base_dir']}/#{subdir}" do
    recursive true
    owner 'root'
    group 'root'
    mode 00755
  end
end

cla_mysql_package node['cla_mysql']['default_package']['version'] do
  url node['cla_mysql']['default_package']['url']
  checksum node['cla_mysql']['default_package']['checksum']
end

cla_mysql_instance 'default' do
  user 'mysql'
  group 'mysql'
  create_user true
end
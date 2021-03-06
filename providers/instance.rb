use_inline_resources

# Import the RandomPassword module from the OpenSSL cookbook, which includes a
# random_password function we'll use later.
include OpenSSLCookbook::RandomPassword

def whyrun_supported?
  true
end

action :create do
  instances_dir = ::File.join(node['multi_mysql']['base_dir'], 'instances')
  instance_root = ::File.join(instances_dir, new_resource.instance_name)

  # Create service account and group if specified
  if new_resource.create_user
    group new_resource.group do
      system true
    end

    user new_resource.user do
      gid new_resource.group
      system true
    end
  end

  directory instances_dir do
    owner 'root'
    group 'root'
    mode 00755
  end

  directory instance_root do
    owner new_resource.user
    group new_resource.group
    mode 00755
  end

  directory instance_root do
    owner new_resource.user
    group new_resource.group
    mode 00755
  end

  %w(data log).each do |subdir|
    directory ::File.join(instance_root, subdir) do
      owner new_resource.user
      group new_resource.group
      mode 00755
    end
  end

  directory "#{instance_root}/etc" do
    owner 'root'
    group 'root'
    mode 00755
  end

  link "#{instance_root}/server" do
    to "../../binaries/#{new_resource.distribution}-#{new_resource.version}"
    # Don't overwrite if the symlink has already been created -
    # could harm an existing instance.
    not_if { ::File.symlink?("#{instance_root}/server") }
  end

  execute "mysql_install_db-#{new_resource.instance_name}" do
    cwd "#{instance_root}/server"
    command "scripts/mysql_install_db --no-defaults --basedir='#{instance_root}/server' --datadir='#{instance_root}/data' --user='#{new_resource.user}'"
    not_if { ::File.directory?("#{instance_root}/data/mysql") }
  end

  config_hash = { mysqld:
                  { basedir: "#{instance_root}/server",
                    datadir: "#{instance_root}/data",
                    socket: "#{instance_root}/mysql.sock",
                    user: new_resource.user,
                    general_log_file: "#{instance_root}/log/mysql.log",
                    slow_query_log_file: "#{instance_root}/log/mysql-slow.log",
                    log_error: "#{instance_root}/log/mysql.err"
                  }
                }
  config_text = ''
  Chef::Mixin::DeepMerge.deep_merge(new_resource.config, config_hash) if new_resource.config
  config_hash.each_pair do |key,value|
    config_text << "[#{key}]\n"
    value.each_pair do |key,value|
      config_text << "#{key}" << (value ? " = #{value}\n" : "\n")
    end
  end

  template "#{instance_root}/etc/my.cnf" do
    source 'my.cnf.erb'
    cookbook 'multi_mysql'
    variables ({my_cnf: config_text})
    notifies :restart, "service[mysqld_#{new_resource.instance_name}]"
  end

  template "/etc/init.d/mysqld_#{new_resource.instance_name}" do
    source 'init.mysqld.erb'
    owner 'root'
    group 'root'
    mode 00755
    cookbook 'multi_mysql'
    variables ({
      instance_root: instance_root
      })
    notifies :restart, "service[mysqld_#{new_resource.instance_name}]"
  end

  service "mysqld_#{new_resource.instance_name}" do
    supports :restart => true, :reload => true, :status => true
    action [:enable, :start]
  end

  # random_password() (from the OpenSSLCookbook::RandomPassword module)
  # defaults to 20 bytes long and hex characters only - we specify base64
  # to include all letters+numbers (plus a few special characters).
  if node['multi_mysql']['instances'].nil? || node['multi_mysql']['instances'][new_resource.instance_name]['server_root_password'].nil?
    node.normal['multi_mysql']['instances'][new_resource.instance_name]['server_root_password'] = random_password(:mode => :base64, :encoding => "ASCII")
    if Chef::Config.local_mode
      node.normal['multi_mysql']['instances'][new_resource.instance_name]['server_root_password'] = node['multi_mysql']['testing_password']
    end
    node.save
  end

  template "#{instance_root}/etc/grants.sql" do
    source 'grants.sql.erb'
    variables ({instance_root: instance_root})
    owner 'root'
    group 'root'
    mode 00600
    sensitive true
    cookbook 'multi_mysql'
    variables ({server_root_password: node['multi_mysql']['instances'][new_resource.instance_name]['server_root_password']})
    notifies :run, "execute[install-grants-#{new_resource.instance_name}]", :immediately
  end

  execute "install-grants-#{new_resource.instance_name}" do
    command "#{instance_root}/server/bin/mysql --defaults-file='#{instance_root}/etc/my.cnf' -S '#{instance_root}/mysql.sock' -u root < '#{instance_root}/etc/grants.sql'"
    only_if "#{instance_root}/server/bin/mysql --defaults-file='#{instance_root}/etc/my.cnf' -S '#{instance_root}/mysql.sock' -u root -e 'show databases;'"
    action :nothing
  end

end

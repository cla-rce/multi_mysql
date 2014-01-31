use_inline_resources

include Opscode::OpenSSL::Password

def whyrun_supported?
  true
end

action :create do
  instance_root = ::File.join(node['multi_mysql']['base_dir'], 'instances', new_resource.instance_name)

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

  directory instance_root do
    owner new_resource.user
    group new_resource.group
    mode 00755
  end

  %w(data log server).each do |subdir|
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

  link "#{instance_root}/server-current" do
    to "../../binaries/mysql-#{new_resource.version}"
  end

  ::Dir.glob("#{node['multi_mysql']['base_dir']}/binaries/mysql-#{new_resource.version}/*").map {|f| ::File.basename(f)}.each do |target|
    link "#{instance_root}/server/#{target}" do
      to "../server-current/#{target}"
    end
  end

  link "#{instance_root}/server/my.cnf" do
    to '../etc/my.cnf'
  end

  execute "mysql_install_db-#{new_resource.instance_name}" do
    cwd "#{instance_root}/server"
    command "scripts/mysql_install_db --basedir='#{instance_root}/server' --datadir='#{instance_root}/data' --user='#{new_resource.user}'"
    not_if { ::File.directory?("#{instance_root}/data/mysql") }
  end

  config_hash = {mysqld: {socket: "#{instance_root}/mysql.sock"}}
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
    variables ({my_cnf: config_text})
    notifies :restart, "service[mysqld_#{new_resource.instance_name}]"
  end

  template "/etc/init.d/mysqld_#{new_resource.instance_name}" do
    source 'init.mysqld.erb'
    owner 'root'
    group 'root'
    mode 00755
    variables ({
      instance_root: instance_root
      })
    notifies :restart, "service[mysqld_#{new_resource.instance_name}]"
  end

  service "mysqld_#{new_resource.instance_name}" do
    supports :restart => true, :reload => true, :status => true
    action [:enable, :start]
  end

  node.set_unless['multi_mysql']['instances'][new_resource.instance_name]['server_root_password'] = secure_password

  execute 'assign-root-password-#{new_resource.instance_name}' do
    command "#{instance_root}/server/bin/mysqladmin -S '#{instance_root}/mysql.sock' -u root password '#{node['multi_mysql']['instances'][new_resource.instance_name]['server_root_password']}'" 
    only_if "#{instance_root}/server/bin/mysql -S '#{instance_root}/mysql.sock' -u root -e 'show databases;'"
  end

  # We've just set the root password on this instance. Save the node object so we don't lose the generated password.
  ruby_block 'save-node-mysql-#{new_resource.instance_name}' do
    block { node.save }
    not_if Chef::Config[:solo]
  end

  template "#{instance_root}/etc/grants.sql" do
    source 'grants.sql.erb'
    variables ({instance_root: instance_root})
    owner 'root'
    group 'root'
    mode 00600
    variables ({server_root_password: node['multi_mysql']['instances'][new_resource.instance_name]['server_root_password']})
    notifies :run, "execute[install-grants-#{new_resource.instance_name}]", :immediately
  end

  execute "install-grants-#{new_resource.instance_name}" do
    command "#{instance_root}/server/bin/mysql -S '#{instance_root}/mysql.sock' -u root < '#{instance_root}/etc/grants.sql' -p'#{node['multi_mysql']['instances'][new_resource.instance_name]['server_root_password']}'"
    action :nothing
  end

end
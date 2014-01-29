use_inline_resources

include Opscode::OpenSSL::Password

def whyrun_supported?
  true
end

action :create do
  instance_root = ::File.join(node['cla_mysql']['base_dir'], 'instances', new_resource.instance_name)

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

  ::Dir.glob("#{node['cla_mysql']['base_dir']}/binaries/mysql-#{new_resource.version}/*").map {|f| ::File.basename(f)}.each do |target|
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

  template "#{instance_root}/etc/my.cnf" do
    source 'my.cnf.erb'
    variables ({my_cnf: "[mysqld]\nsocket = #{instance_root}/mysql.sock"})
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

  node.set_unless['cla_mysql']['instances'][new_resource.instance_name]['server_root_password'] = secure_password

  template "#{instance_root}/etc/grants.sql" do
    source 'grants.sql.erb'
    variables ({instance_root: instance_root})
    owner 'root'
    group 'root'
    mode 00600
    variables ({server_root_password: node['cla_mysql']['instances'][new_resource.instance_name]['server_root_password']})
    notifies :run, "execute[install-grants-#{new_resource.instance_name}]", :immediately
  end

  execute "install-grants-#{new_resource.instance_name}" do
    command "#{instance_root}/server/bin/mysql -S '#{instance_root}/mysql.sock' -u root < '#{instance_root}/etc/grants.sql'"
    action :nothing
  end

end
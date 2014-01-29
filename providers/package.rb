use_inline_resources

def whyrun_supported?
  true
end

action :install do
  if mysql_package_installed?
    Chef::Log.info "#{new_resource} already installed - nothing to do."
  else
    converge_by("Install #{new_resource}") do
      install_mysql_package
    end
  end
end

def install_mysql_package
  package 'libaio1'

  ark "mysql-#{new_resource.version}" do
    url new_resource.url
    checksum new_resource.checksum
    path ::File.join(node['cla_mysql']['base_dir'], "binaries")
    action :put
  end
  
  new_resource.updated_by_last_action(true)
end

def mysql_package_installed?
	::File.directory?(::File.join(node['cla_mysql']['base_dir'], "binaries", "mysql-#{new_resource.version}"))
end
use_inline_resources

def whyrun_supported?
  true
end

action :install do
  package 'libaio1'

  install_dir = ::File.join(node['multi_mysql']['base_dir'], "binaries")

  directory install_dir do
    owner 'root'
    group 'root'
    mode 00755
  end

  ark "mysql-#{new_resource.version}" do
    url new_resource.url
    checksum new_resource.checksum
    path install_dir
    action :put
  end
end
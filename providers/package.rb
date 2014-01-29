use_inline_resources

def whyrun_supported?
  true
end

action :install do
  package 'libaio1'

  ark "mysql-#{new_resource.version}" do
    url new_resource.url
    checksum new_resource.checksum
    path ::File.join(node['cla_mysql']['base_dir'], "binaries")
    action :put
  end
end
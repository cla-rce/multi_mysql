use_inline_resources

def whyrun_supported?
  true
end

action :install do
  package 'libaio1'
  package 'libjemalloc1'

  base_dir = node['multi_mysql']['base_dir']
  install_dir = ::File.join(base_dir, "binaries")

  [base_dir, install_dir].each do |subdir|
    directory subdir do
      owner 'root'
      group 'root'
      mode 00755
    end
  end

  ark "#{new_resource.distribution}-#{new_resource.version}" do
    url new_resource.url
    checksum new_resource.checksum
    path install_dir
    action :put
  end
end

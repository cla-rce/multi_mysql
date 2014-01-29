actions :create
default_action :create
attribute :instance_name, :name_attribute => true, :kind_of => String, :required => true
attribute :version, :kind_of => String, :required => false, :default => node['cla_mysql']['default_package']['version']
attribute :user, :kind_of => String, :required => true
attribute :group, :kind_of => String, :required => true
attribute :create_user, :kind_of => [TrueClass, FalseClass], :required => false, :default => false
attribute :config, :kind_of => Hash, :required => false
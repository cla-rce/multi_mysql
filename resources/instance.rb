actions :create
default_action :create
attribute :instance_name, :name_attribute => true, :kind_of => String, :required => true
attribute :distribution, :kind_of => String, :required => true, :equal_to => ['mysql', 'mariadb'], :default => node['multi_mysql']['default_package']['distribution']
attribute :version, :kind_of => String, :required => true, :regex => /^[0-9]+\.[0-9]+\.[0-9]+/, :default => node['multi_mysql']['default_package']['version']
attribute :user, :kind_of => String, :required => true, :regex => /^[-_a-z0-9]+$/i
attribute :group, :kind_of => String, :required => true, :regex => /^[-_a-z0-9]+$/i
attribute :create_user, :kind_of => [TrueClass, FalseClass], :required => false, :default => false
attribute :config, :kind_of => Hash, :required => false

actions :install
default_action :install
attribute :version, :name_attribute => true, :kind_of => String, :required => true
attribute :url, :kind_of => String, :required => true
attribute :checksum, :kind_of => String, :required => true
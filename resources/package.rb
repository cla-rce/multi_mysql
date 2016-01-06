actions :install
default_action :install
attribute :distribution, :kind_of => String, :required => true, :equal_to => ['mysql', 'mariadb']
attribute :version, :kind_of => String, :required => true, :regex => /^[0-9]+\.[0-9]+\.[0-9]+/
attribute :url, :kind_of => String, :required => true
attribute :checksum, :kind_of => String, :required => true, :regex => /^[a-f0-9]{64}$/

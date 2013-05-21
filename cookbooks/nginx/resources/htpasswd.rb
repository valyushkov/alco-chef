actions :add, :delete, :update

attribute :user, :kind_of => String, :name_attribute => true, :required => true
attribute :password, :kind_of => String, :default => 'dJTd4v1K'
attribute :file,  :kind_of => String, :default => '/etc/nginx/htpassword'

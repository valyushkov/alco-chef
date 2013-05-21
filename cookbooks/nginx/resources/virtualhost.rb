actions :add, :delete, :enable, :disable

attribute :vhname,
  :kind_of => String,
  :name_attribute => true

attribute :template,
  :kind_of => String

attribute :options,
  :kind_of => Hash,
  :default => {}

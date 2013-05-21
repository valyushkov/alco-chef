actions :add, :enable, :disable, :restart

attribute :service_name,
  :kind_of => String,
  :name_attribute => true

attribute :run_script_template,
  :kind_of => String

attribute :finish_script_template ,
  :kind_of => String

attribute :log_run_script_template,
  :kind_of => String

# verm666. 2012.07.16
# Не совсем обычный атрибут. Если в значении атрибута есть символ
# перевода строки - мы считаем, что это не имя шаблона, а
# тело итогового файла. Делается это для того, что нельзя
# из провайдера получить доступ к шаблону другого cookbook-а.
# И просто положить шаблон в runit/template/default нельзя, так как
# искать его chef будет в cookbook-e, из которого вызывается ресурс.
attribute :log_config_template,
  :kind_of => String,
  :default => "s104857600\nn10\nt86400"

attribute :log_directory,
  :kind_of => String

attribute :control_t_script_template,
  :kind_of => String

attribute :urls_to_view,
  :kind_of => Array,
  :default => []

attribute :files_to_view,
  :kind_of => Array,
  :default => []

attribute :files_to_watch,
  :kind_of => Array,
  :default => []

attribute :options,
  :kind_of => Mash


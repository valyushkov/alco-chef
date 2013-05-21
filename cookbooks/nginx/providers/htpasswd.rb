def gen_salt(size = 8)
  charset = %w{ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ! @ # $ % ^ & * ( ) _ + }
  (0...size).map{ charset.to_a[rand(charset.size)] }.join
end

def gen_password(salt, password)
  password.crypt(salt)
end


action :add do

  user = new_resource.user
  password = new_resource.password
  file = new_resource.file
  if not ::File.exists?(file) then
    ::File.new(file, "w")
  end

  salt = gen_salt(size = 8)
  password = gen_password(salt, password)
  str = user+':'+password

  text = ::File.read(file)
  regexp = %r{^#{user}:}
  if not text =~ regexp then
    ::File.open(file, "a+") { |f| f.puts(str) }
  end

end

action :delete do
  user = new_resource.user
  file = new_resource.file
  if not ::File.exists?(file) then
    ::File.new(file, "w")
  end

  text = ::File.read(file)
  replace = text.gsub!(/#{user}:.*/, '')
  replace = replace.gsub!(/^$\n/, '')
  ::File.open(file, "w+") { |f| f << replace }
end

action :update do
  user = new_resource.user
  password = new_resource.password
  file = new_resource.file
  if not ::File.exists?(file) then
    ::File.new(file, "w")
  end

  salt = gen_salt(size = 8)
  password = gen_password(salt, password)
  str = user+':'+password

  text = File.read(file)
  replace = text.gsub!(/#{user}:.*/, str)
  ::File.open(file, "w+") { |f| f << replace }
end

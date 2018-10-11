require 'yaml'
module Init_m

def parse_yml    

 unless File.exists?("id_ini.yml")
    File.new("id_ini.yml", "w+")
 end

 init_var = YAML.load_file("id_ini.yml")
  return init_var
end

def set_root_folder(folder)

 dir = {
   'root_folder' => "#{folder}"}       
     File.open("id_ini.yml", "r+") do |f|
      f.write(dir.to_yaml)
     end

end    
module_function :parse_yml
module_function :set_root_folder
end
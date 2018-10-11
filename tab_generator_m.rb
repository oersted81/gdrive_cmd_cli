require 'tty-table'
require 'slop'
require 'diffy'
require_relative 'init_m.rb'

module Tab_generator_m

include Init_m

def list_current_folder    
  gdrive = %x(gdrive list --query " '#{Init_m.parse_yml["root_folder"]}' in parents")

  tab = []
  grid = []
  gdrive.each_line {|s| tab << s}
  tab.shift(1).slice_after('\n').to_a
  tab.each_index {|i| tab[i] = tab[i].split(%r{\s}).delete_if {|score| score == "" }}

  for i in 0..tab.length.to_i - 1
   grid << [i, tab[i][1], tab[i][0], tab[i][2]]
  end

  $table = TTY::Table.new ['No.', 'Name', 'ID', 'Type'],  grid

  puts $table.render(:ascii)
 return grid

end

def mkdir
  puts "Create new dir:"
  st = STDIN.gets.chomp
  gdrive = %x(gdrive mkdir -p "#{Init_m.parse_yml["root_folder"]}" "#{st}")
  puts gdrive
end

def chdir    
  new_rf = list_current_folder 
  puts "Set new root folder:"    
  sel_folder = STDIN.gets.chomp   
  Init_m.set_root_folder(new_rf[sel_folder.to_i][2])
end    

module_function :list_current_folder
module_function :mkdir
module_function :chdir
end
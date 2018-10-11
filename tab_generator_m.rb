require 'tty-table'
require 'slop'
require 'diffy'
require 'pastel'
require_relative 'init_m.rb'

def show_path
  tab = []
  grid = []
  gdrive = %x(gdrive list --query " '#{Init_m.parse_yml["root_folder"]}' in parents" --absolute)
  gdrive.each_line {|s| tab << s}
  tab.shift(1).slice_after('\n').to_a
  tab.each_index {|i| tab[i] = tab[i].split(%r{\s}).delete_if {|score| score == "" }}

  for i in 0..tab.length.to_i - 1
   grid << [i, tab[i][1], tab[i][0], tab[i][2]]
  end
  split_path = grid[0][1].split(/\//)
  length_sp = split_path.length.to_i
  if length_sp == 3
    path = "current path: /#{split_path[0]}/#{split_path[1]}/"
  elsif length_sp == 2
    path = "current path: /#{split_path[0]}/"  
  end
  return length_sp, path
end  

module Tab_generator_m

include Init_m

def show_table(arry)
table = TTY::Table.new ['No.', 'Name', 'ID', 'Type'],  arry
return table.render(:ascii, multiline: true)
end

def list_current_folder(path)   
  tab = []
  grid = []
  if path == "--absolute"
    gdrive = %x(gdrive list --query " '#{Init_m.parse_yml["root_folder"]}' in parents" "#{path}")   
  elsif path == ""
    gdrive = %x(gdrive list --query " '#{Init_m.parse_yml["root_folder"]}' in parents")
  end
  gdrive.each_line {|s| tab << s}
  tab.shift(1).slice_after('\n').to_a
  tab.each_index {|i| tab[i] = tab[i].split(%r{\s}).delete_if {|score| score == "" }}

  for i in 0..tab.length.to_i - 1
   grid << [i, tab[i][1], tab[i][0], tab[i][2]]
  end
 return grid
end

def mkdir
  puts show_path[1]
  puts "Create new dir:"
  st = STDIN.gets.chomp
  gdrive = %x(gdrive mkdir -p "#{Init_m.parse_yml["root_folder"]}" "#{st}")
  puts gdrive
end

def chdir   
  f = []
  puts show_path[1]
  puts "change working dir or revert to root(c/r)"
  st = STDIN.gets.chomp
  case st
   when 'c'
    f = list_current_folder("").flatten.each_slice(4).to_a
    n = []
    f.each_index {|i| n <<  f[i] if f[i][3] == 'dir' }
    puts show_table(n)
    puts "Set new master folder:"    
    sel_folder = STDIN.gets.chomp   
    Init_m.set_root_folder(f[sel_folder.to_i][2])
 
    puts show_table(list_current_folder(""))

   when 'r'
    if show_path[0] == 3
    Init_m.set_root_folder(Init_m.parse_yml["master_folder"])

      puts show_table(list_current_folder(""))
    elsif show_path[0] == 2
      puts "nothing changed, you are in #{show_path[1]}"
    end
   else puts "wrong arg"
  end
end    

def upl
  puts show_path[1]
  puts "File name?:"
  sf = STDIN.gets.chomp
  std = %x(gdrive upload "#{sf}" --parent "#{Init_m.parse_yml["root_folder"]}")
end

def upd
  puts show_path[1]
  puts show_table(list_current_folder(""))
  puts "Select file:"
  sf = STDIN.gets.chomp
  gdrive_diff1 = %x(gdrive download --stdout "#{list_current_folder("")[sf.to_i][2]}" --path "#{Init_m.parse_yml["root_folder"]}")
  std = %x(gdrive update "#{list_current_folder("")[sf.to_i][2]}" "#{list_current_folder("")[sf.to_i][1]}")
  puts %x(gdrive info "#{list_current_folder("")[sf.to_i][2]}")
  gdrive_diff2 = %x(gdrive download --stdout "#{list_current_folder("")[sf.to_i][2]}" --path "#{Init_m.parse_yml["root_folder"]}")
  color_line = Pastel.new
  Diffy::Diff.new("#{gdrive_diff1}", "#{gdrive_diff2}", :context => 1).each do |line|
    case line
      when /^\+/ then puts color_line.green("#{line.chomp}")
      when /^-/  then puts color_line.red("#{line.chomp}")
      end
    end  
end

def del
   puts show_path[1]
   puts show_table(list_current_folder(""))
   puts "Select file:"
   sf = STDIN.gets.chomp
   std = %x(gdrive delete "#{list_current_folder("")[sf.to_i][2]}")
end 

def sr
  puts show_path[1]
  puts show_table(list_current_folder(""))
  puts 'Select file to list revisions:'
  sf = STDIN.gets.chomp
  std = %x(gdrive revision list "#{list_current_folder("")[sf.to_i][2]}")
  gd_ary2 = std.split(/\s/)
  gd = gd_ary2.delete_if {|score| score == ""}
  gd.shift(5)
  tab = []
  tab2 = []
  tab = gd.slice_after(/False|True/).to_a
  tab.each_index {|i| tab2 << [i, tab[i][1], tab[i][0], tab[i][5], tab[i][4]] }
  table = TTY::Table.new tab2
  puts table.render(:ascii, multiline: true, resize: true)
  puts "Download revision index:?"
  sf2 = STDIN.gets.chomp 
  std2 = %x(gdrive revision download -f "#{list_current_folder("")[sf.to_i][2]}" "#{tab2[sf2.to_i][2]}") 
  puts std2

end

def dwn 
  puts show_path[1]
  puts show_table(list_current_folder(""))
  puts "Select file:"
  sf = STDIN.gets.chomp
  puts "where? current: #{%x(pwd)}"
  location = STDIN.gets.chomp
  if location == ""
   std = %x(gdrive download "#{list_current_folder("")[sf.to_i][2]}")  
  else
   std = %x(gdrive download "#{list_current_folder("")[sf.to_i][2]}")
   puts std
   %x(mv "#{list_current_folder("")[sf.to_i][1]}" -t "#{location}")
  end
end
module_function :list_current_folder
module_function :mkdir
module_function :chdir
module_function :show_table
module_function :upl
module_function :upd
module_function :del
module_function :sr
module_function :dwn
end
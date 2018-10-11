require_relative 'tab_generator_m.rb'

arg = ARGV[0]

begin

case arg
 when '-l'
  puts Tab_generator_m.show_table(Tab_generator_m.list_current_folder(""))
 when '-md'
   Tab_generator_m.mkdir
 when '-chd'
   Tab_generator_m.chdir
 when '-upl'
   Tab_generator_m.upl
 when '-upd'
   Tab_generator_m.upd  
 when '-dwn'
   Tab_generator_m.dwn  
 when '-del'
   Tab_generator_m.del  
 when '-sr'
   Tab_generator_m.sr    
 when '-h'
help = """-l   -> list current folder
-md  -> mkdir
-chd -> change root folder in parent script_folder
-upl -> upload new file
-sr  -> show revisions, opt. download rev.
-upd -> update file
-dwn -> download file(force)
-del -> delete file
-h   -> help
"""
puts help
 else
    puts "wrong arg"
 end

rescue Interrupt
    puts "tak cus picus"
end
require_relative 'tab_generator_m.rb'

arg = ARGV[0]

begin

case arg
 when '-l'
   Tab_generator_m.list_current_folder
 when '-md'
   Tab_generator_m.mkdir
 when '-chd'
   Tab_generator_m.chdir
 else
    puts "wrong arg"
 end

rescue Interrupt
    puts "tak cus picus"
end
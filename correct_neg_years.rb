#!/usr/bin/ruby
# Corrects negative years in v4_main_table_text_sorted. 
# If year is 6xxxx, then change that to a properly represented negative year

f = File.open 'v4_main_table_text_sorted_wrongnegyears'  # Note: negative years are represented incorrectly as 65536 - true year: must correct!
g = File.open 'v4_main_table_text_sorted','w'

# process the lines of the input file
while l = f.gets
  l.chomp!
  l =~ /^"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,(.*)$/
  # fields 4 and 5 are the year fields
  old1 = $1  # I know, I should be doing this the OO way!!!!!!
  old2 = $2
  old3 = $3
  old4 = $4
  old5 = $5
  old6 = $6
  if old4 =~ /6\d\d\d\d/
    new4 = (old4.to_i - 65536).to_s
    puts "Changed field 4 year from #{old4} to #{new4}"
  else
    new4 = old4
  end
  if old5 =~ /6\d\d\d\d/
    new5 = (old4.to_i - 65536).to_s
    puts "Changed field 5 year from #{old5} to #{new5}"
  else
    new5 = old5
  end
  newl = "\"#{old1}\",\"#{old2}\",\"#{old3}\",\"#{new4}\",\"#{new5}\",#{old6}"
  g.puts newl 
  if old4 != new4 or old5 != new5
    puts 'EDITING PERFORMED: '
    puts 'OLD LINE:' + l
    puts 'NEW LINE:' + newl
  end # if
end # while


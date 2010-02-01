#!/usr/bin/ruby
# This program turns the text file representing the CHGIS v4 main table
# into one where each entry is preceded with a running id, just for
# ease of identification of the entries.

infile = File.open('v4_main_table_text')
outfile = File.open('v4_main_table_text_indexed', 'w')
# Process first line
l = infile.gets
outfile.print '"id",'+ l

# Process that data lines
id = 0
while l = infile.gets
  id = id+1
  outfile.print '"' + id.to_s + '",' + l
end # while

infile.close
outfile.close

#!/usr/bin/ruby
# Creates a version of the main table with just the names and types
# in Pinyin and in CH Chinese characters, as if to do
# select 'name_py', 'type_py', 'name_ch', 'type_ch' from 'v4_main_table'

# We'll consider the type as being spiritually part of the name.  That is,
# if place named n of type x is different from a place named n of type y.

f = File.open 'v4_main_table_text_sorted'  # Note: negative years are represented incorrectly as 65536 - true year: must correct!
g = File.open 'v4_main_table_overlapping_time_same_name_entries','w'

# process the lines of the input file
while l = f.gets
  l =~ /"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"/
  g.puts "\"#{$1}\",\"#{$2}\",\"#{$12}\",\"#{$17}\""
end # while


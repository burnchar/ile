#!/usr/bin/ruby
# Reads the 'v4_main_table_name_type_sorted' file and produces a file
# with unique entries.

# Also analyzes the input and reports on entries that are the same inj
# Pinyin but different in CH.  We assume that the Chinese name is the
# definitive one so that if the Chinese name of two entries are the
# same then the Pinyin names should also be the same, even though in
# general the same Chinese character can have two different pronunciations
# in different contexts. (Let me know if this assumption is incorrect!)

f = File.open 'v4_main_table_name_type_sorted'
g = File.open 'v4_main_table_name_type_unique','w'

h = File.open 'v4_same_py_diff_ch','w'

uniquecount = 0
name_type_ch_diff = 0
name_ch_diff = 0
type_ch_diff = 0

old_name_py = ''
old_type_py = ''
old_name_ch = ''
old_type_ch = ''

while l = f.gets
  l =~ /"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"/
  name_py = $1
  type_py = $2
  name_ch = $3
  type_ch = $4

  if name_py != old_name_py or type_py != old_type_py or
      name_ch != old_name_ch or type_ch != old_type_ch
    g.puts "#{name_py}, #{type_py}, #{name_ch}, #{type_ch}"
    uniquecount = uniquecount + 1
    if name_py == old_name_py and type_py == old_type_py
      if name_ch != old_name_ch and type_ch != old_type_ch
        name_type_ch_diff = name_type_ch_diff + 1
        h.print "Chinese NAMES and TYPES Differ: "
        h.print " CURRENT: #{name_py}, #{type_py}, #{name_ch}, #{type_ch}"
        h.puts "  PREVIOUS: #{old_name_py}, #{old_type_py}, #{old_name_ch}, #{old_type_ch}"
      elsif name_ch != old_name_ch
        name_ch_diff = name_ch_diff + 1
        h.print "Chinese NAMES Differ: "
        h.print " CURRENT: #{name_py}, #{type_py}, #{name_ch}, #{type_ch}"
        h.puts "  PREVIOUS: #{old_name_py}, #{old_type_py}, #{old_name_ch}, #{old_type_ch}"
      else # only Chinese types differ
        type_ch_diff = type_ch_diff + 1
        h.print "Chinese TYPES Differ: "
        h.print " CURRENT: #{name_py}, #{type_py}, #{name_ch}, #{type_ch}"
        h.puts "  PREVIOUS: #{old_name_py}, #{old_type_py}, #{old_name_ch}, #{old_type_ch}"
      end # if, inner
    end # if, middle
  end # if, outer

  old_name_py = name_py
  old_type_py = type_py
  old_name_ch = name_ch
  old_type_ch = type_ch
  
end # while

puts "TOTAL NUMBER OF UNIQUE ENTRIES: #{uniquecount}"
puts "SAME PINYIN, DIFF CH NAMES AND TYPES: #{name_type_ch_diff}"
puts "SAME PINYIN, DIFF CH NAMES: #{name_ch_diff}"
puts "SAME PINYIN, DIFF CH TYPES: #{type_ch_diff}"


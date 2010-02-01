#!/usr/bin/ruby
# Opens up a file that consists of lines of text, where each line has one or
# more double-quoted items, and counts the number of lines with unique first
# double-quoted items.

# Assumption: lines are sorted by first double-quoted items

# Also reports on all lines whose first double-quoted item contains
# characters other than A-Z, a-z, and the single quote.  This is a
# feature to catch untranslated Chinese or other non-English characters.

if (filename = ARGV[0]) == nil
  puts 'Usage: give file name as inline argument'
  exit
end # if
puts 'The filename you supplied is ' + filename
 
f = File.open filename

num_unique_lines = 0
num_non_unique_lines = 0
oldfirstitem = ''
currentfirstitem = ''
firstline = true
while l = f.gets

  # Report irregularities in the first entry
  if l =~ /^"([^"]*?[^A-Za-z '",][^"]*?)"/
    puts 'IRREGULAR FIRST ENTRY FOUND: ' + $1
  end # if

  if firstline
    num_unique_lines = 1
    l =~ /"(.*?)"/
    oldfirstitem = $1
    firstline = false
  else
    l =~ /"(.*?)"/
    currentfirstitem = $1
#    puts "Current, old first items = #{currentfirstitem}, #{oldfirstitem}"
    if currentfirstitem == oldfirstitem
#      puts "***Current same as old!!!***"
      num_non_unique_lines = num_non_unique_lines + 1
    else
#      puts "****UNIQUE ITEM FOUND!!!***"
      num_unique_lines = num_unique_lines + 1
    end # if - inner
    oldfirstitem = currentfirstitem
  end # if firstline - else
end # while l = f.gets
puts "Total lines with unique first items = #{num_unique_lines}"
puts "Total lines with same first item as previous line = #{num_non_unique_lines}"

#!/usr/bin/ruby
# Opens up the text file representing the CHGIS v4_preceded_by_table
# and makes a hash-of-hash saying what feature type is preceded by
# what feature type.

# For example, POINT 41166 is preceded by 41165, and so
# prechash[41166] = 41165
# typehash[41166] = :point

# We also need to store beginning type change, so
# begchghash[41166] = whatever... will translate the Chinese!

# For now we're trying to ignore other entries in that table,
# such as names, coordinate and years, hoping that they are
# not really needed 

# Assume that the file comes with a header line, which is tossed.

# Table (Hash) translating Chinese change type to English change type
changetype = Hash.new
g = File.open 'xtra_change_type_text'
# throw away firstline
l = g.gets
while l = g.gets
  l =~ /"(.*?)"\,"(.*?)"\,"(.*?)"/
  changetype[$3] = $1
end # while
puts 'change type dictionary:'
puts changetype.inspect

filename = 'v4_preceded_by_text'
f = File.open filename

typehash = Hash.new # this is 'POLYGON' or 'POINT', might as well make this
# an array too, like the others below...
predhash = Hash.new # each value is an array because there may be more than one
changereasonhash = Hash.new # each value is an array parallel to the predhash
# array, although all values may be the same (just in case they aren't the same)
beginyearhash = Hash.new # again each value is an array, parallel to 
# the other two arrays above. 
# Got to keep this because a feature may not occur at
# a unique time.  For instance, you may have polygon 14100 once in year 800
# and again at year 1000 (made-up example). The one in year 800 may have oe
# precedence, but the on in year 1000 may have a different precedence.

# throw away first line
f.gets
while l = f.gets
  l =~ /"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"/ # $1 is pro_id, $7 is proby_id, $12 is beg_chg_ty
#  puts "Just read the line #{$1}, #{$4}, #{$5}, #{$7}, #{$12}, #{changetype[$12]}"
  
  typehash[$1] = Array.new if !typehash[$1]
  typehash[$1].push $6
  predhash[$1] = Array.new if !predhash[$1]
  predhash[$1].push $7
  changereasonhash[$1] = Array.new if !changereasonhash[$1]
  changereasonhash[$1].push changetype[$12]
  beginyearhash[$1] = Array.new if !beginyearhash[$1]
  beginyearhash[$1].push $4
  
end # while l = f.gets
puts 'RESULTING HASHES'
typehash.each_key do |i|
  puts "PRO_ID = #{i}:"
  puts "  typehash[#{i}] = #{typehash[i].inspect}"
  puts "  predhash[#{i}] = #{predhash[i].inspect}"
  puts "  changereasonhash[#{i}] = #{changereasonhash[i].inspect}"
  puts "  beginyearhash[#{i}] = #{beginyearhash[i].inspect}"
  puts "-------------------------------------------------------"
end

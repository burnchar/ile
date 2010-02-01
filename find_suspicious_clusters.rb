#!/usr/bin/ruby
require 'utilities'
# Corrects negative years in v4_main_table_text_sorted. 
# If year is 6xxxx, then change that to a properly represented negative year
SUSPICIOUS_DISTANCE = 2.0
suspicious_count = 0
semi_suspicious_count = 0
f = File.open 'v4_main_table_text_sorted'  # Note: negative years are now represented correctly!
g = File.open 'v4_main_table_suspicious_similar_entries','w'

# process the lines of the input file
# make an array of arrays of entry groups with unique Pinyin names
# A pair of entries is said to be a "suspicious pair" if they ....
# (1) have the same Pinyin name, (forget the type and Chinese name and type),
# (2) overlap in time, and,
# (3) are within SUSPICIOUS_DISTANCE degrees different in both latitude and longitude

# if only conditions (1) and (2) are satisfied but not (3) then the name is semi_suspicious!!!

oldline = nil
array_of_row_groups = Array.new
new_row_group = Array.new
while l = f.gets
  l.chomp!

# Fields of interest: $1: name, $4: begin year, $5: end year, $10: x (longitude), $11: y (latitude)  
  l =~ /^"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,(.*)$/

  new1 = $1  # Pinyin name; I know, I should be doing this the OO way!!!!!!
  new4 = $4  # begin year
  new5 = $5  # end year
  new10 = $10 # x
  new11 = $11 # y
  new12 = $12 # the rest

  if oldline != nil
    oldline =~ /^"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,(.*)$/
    old1 = $1  # Pinyin name; I know, I should be doing this the OO way!!!!!!
    old4 = $4  # begin year
    old5 = $5  # end year
    old10 = $10 # x
    old11 = $11 # y
    old12 = $12 # the rest
  end
# Actually, at this point all we need to do is to compare the Pinyin names, $1

  if oldline == nil or old1 != new1
    new_row_group = Array.new
    array_of_row_groups.push new_row_group
  end # else new_row_group stays as it was
  
  new_row_group.push l
  oldline = l
end # while

# At this point, we have an Array of Arrays of rows of database entries with the same Pinyin names
# Print only the semi-suspicious and suspicious entries!
array_of_row_groups.each_with_index{|x,i|
  # get the name
  x[0] =~ /^"(.*?)"/
  pyname = $1
  puts "----------------------------------------------"
  puts "Examining Pinyin name number #{i+1}: #{pyname}"
  # puts x[0]
  # Mark the entries with this Pinyin name suspicious if the years overlap at all and if the 
  # x and y coordinates differ by within SUSPICIOUS_DISTANCE degrees each
  # Note: Mark "semi-suspicious" if just the years overlap
  suspicious = false
  semi_suspicious = false
  0.upto(x.size-2){|m|
    (m+1).upto(x.size-1){|n|
      # Compare entries m and n
      x[m] =~ /^"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,(.*)$/
      xm1 = $1  # Pinyin name; I know, I should be doing this the OO way!!!!!!
      xm4 = $4  # begin year
      xm5 = $5  # end year
      xm10 = $10 # x
      xm11 = $11 # y
      xm12 = $12 # the rest
      x[n] =~ /^"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,(.*)$/
      xn1 = $1  # Pinyin name; I know, I should be doing this the OO way!!!!!!
      xn4 = $4  # begin year
      xn5 = $5  # end year
      xn10 = $10 # x
      xn11 = $11 # y
      xn12 = $12 # the rest
      
      # Make year ranges:
      xmrange = Range.new(xm4.to_i, xm5.to_i)
      # puts "xmrange = #{xmrange.to_s}"
      xnrange = Range.new(xn4.to_i, xn5.to_i)
      # puts "xnrange = #{xnrange.to_s}"
      # Test for semi_suspiciousness!!
      if xmrange.overlap? xnrange
        semi_suspicious = true
        # puts "Setting semi_suspicious to #{semi_suspicious}"
        # Now test for full suspiciousness!!
        if (xm10.to_i - xn10.to_i).abs <= SUSPICIOUS_DISTANCE and (xm11.to_i - xn11.to_i).abs <= SUSPICIOUS_DISTANCE
          suspicious = true
          # puts "Setting suspicious to #{suspicious}"
        end # if
      end # if
    }
  }
  if semi_suspicious and !suspicious
    semi_suspicious_count = semi_suspicious_count + 1
    puts "SEMI-SUSPICIOUS PINYIN NAME #{semi_suspicious_count} - THERE'S A PAIR OF ENTRIES WITH OVERLAPPING YEAR RANGES!!!"
  end
  if suspicious
    suspicious_count = suspicious_count + 1
    puts "SUSPICIOUS PINYIN NAME #{suspicious_count} - THERE'S A PAIR OF ENTRIES WITH OVERLAPPING YEAR RANGES THAT ARE WITHIN DISTANCE TOLERANCE OF EACH OTHER!!!!!!"
  end
  if semi_suspicious or suspicious
    x.each{|y|
      puts y
    }
  
  end # if
}

puts "Total number of semi-suspicious (but not suspicious) names = #{semi_suspicious_count}"
puts "Total number of suspicious names = #{suspicious_count}"

#!/usr/bin/ruby
# By Vitit Kantabutra, Jan 2010
# Makes connected graphs of historical instances of CHGIS. Each connected
# graph represents all the historical instances that are mutually reachable
# via predecessor-successor relationships. Basically each graph represents
# the transitive closure of any one historical instance in the graph
# under the pred/succ relationships.

# First read the v4 main table, with line indices added, and turn that
# into an array of historical instances.  For now we won't keep very much
# info in each instances, but that may change as needed.
require 'yaml'
class HistInst
  def initialize(id, name_py, type_py, lev_rank, beg_yr, end_yr, bou_id, pt_id, x_coor, y_coor, name_ch, name_ft)
    @id = id
    @name_py = name_py
    @type_py = type_py
    @lev_rank = lev_rank
    @beg_yr = beg_yr # Expects integer - must subtract 65536 if it should be neg
    @end_yr = end_yr # same
    @bou_id = bou_id
    @pt_id = pt_id
    @x_coor = x_coor # expects float
    @y_coor = y_coor # expects float
    @name_ch = name_ch
    @name_ft = name_ft
    
    # Marking field for traversal
    @marked = false
    # Arrays of linkages
    @preds = Array.new
    @succs = Array.new
  end # initializer
  attr_reader :id, :name_py, :type_py, :lev_rank, :beg_yr, :end_yr, :bou_id, :pt_id, :x_coor, :y_coor, :name_ch, :name_ft
  attr_accessor :preds, :succs
end # class HistInst

NumHistInst = 58399 # just to help initialize array to speed processing

ahi = Array.new(NumHistInst)  # array of historical instances.
f = File.new 'v4_main_table_text_indexed'
hhi_bou = Hash.new # hash of hist insts by boundary id
hhi_pt  = Hash.new # hash of hist insts by pt id

# toss first line
l = f.gets

neither_id = 0
num_no_bou_id = 0
num_no_pt_id = 0
while l = f.gets
  l =~ /"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"/
  # $1 = id
  # $2 = name_py
  # $3 = type_py
  # $4 = lev_rank
  # $5 = beg_yr
  # $6 = end_yr
  # $9 = bou_id
  # $10 = pt_id
  # $11 = x_coor
  # $12 = y_coor
  # $13 = name_ch
  # $14 = name_ft
 
  lev_rank = $4.to_i
  beg_yr = $5.to_i
  beg_yr = beg_yr - 65536 if beg_yr > 10000
  end_yr = end_yr = 65536 if beg_yr > 10000
  end_yr = $6.to_i
  x_coor = $11.to_f
  y_coor = $12.to_f

  h = HistInst.new($1, $2, $3, lev_rank, beg_yr, end_yr,
                   $9, $10, x_coor, y_coor, $13, $14)
  ahi.push h
  if $9 != ''
    hhi_bou[$9] = Array.new if !hhi_bou[$9]
    hhi_bou[$9].push h
  else
    num_no_bou_id = num_no_bou_id + 1
    # puts "ACHTUNG: Entry #{h.id} has no boundary id!"
  end # if
  if $10 != ''
    hhi_pt[$10] = Array.new if !hhi_pt[$10]
    hhi_pt[$10].push h
  else
    num_no_pt_id = num_no_pt_id + 1
    puts "ACHTUNG: Entry #{h.id} has no pt id!"
  end # if
  if $9 == '' and $10 == ''
    puts "ACHTUNG: No pt id AND no boundary id!!!!!"
    neither_id = neither_id + 1
  end

end # while

puts "Number of entries with no bou id, no pt id, neither id = #{num_no_bou_id}, #{num_no_pt_id}, #{neither_id}"

f.close

# Now go through the preceded_by file, linking historical instances together
# as we do.

g = File.open('v4_preceded_by_text')
# throw away first line
g.gets

# number of pairs of historical instance pred-succ
num_hi_pairs = 0

while l = g.gets
  l =~ /"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"\,"(.*?)"/
  pro_id = $1
  beg_yr = $4.to_i
  obj_type = $6
  proby_id = $7
  
#  puts "Processing line in preceded_by file with PRO_ID = #{pro_id}"

  # ignore if precedent id is 0
  if $7 == "0"
    next
  end # if

  # if the begin dates match, that's it!
  hi = nil
  if obj_type == 'POINT'
    hi  = hhi_pt[pro_id]
  elsif obj_type == 'POLYGON'
    hi = hhi_bou[pro_id]
  else
    puts "UNKNOWN OBJECT TYPE #{obj_type}, IGNORING!!"
  end # if
  
  if hi
    hi.each{|x|
      # x is an HistInst object 
      puts "--------------------------------"
      puts "For PRO_ID = #{pro_id}:"
#     puts "Historical Instance with that pro_id: #{x.inspect}"

#     puts "Now the CONNECTION: "
      if obj_type == 'POINT'
        pred_hi_array = hhi_pt[proby_id]
      else # obj_type must be 'POLYGON'
        pred_hi_array = hhi_bou[proby_id]
      end # if
      # Go through the potential predecessor hist insts one at a time,
      # considering only those whose ending year is one less than
      # the current records beginning year
      pred_hi_array.each{|phi|
        if phi.end_yr == x.beg_yr - 1
          puts "LINKING TRUE PREDECESSOR-SUCCESSOR HIST. INST. PAIR!"
          puts "SUCC: #{pro_id}  #{x.name_py}  #{x.beg_yr} to #{x.end_yr}"
          puts "PRED: #{proby_id}  #{phi.name_py}  #{phi.beg_yr} to #{phi.end_yr}"
          num_hi_pairs = num_hi_pairs+1
          # Link the two hist insts together!
          phi.succs.push x
          x.preds.push phi
        end # if
      } if pred_hi_array
    }
  else
    puts 'hi is NIL - no historical instances!'
  end

end # while l = g.gets
puts "TOTAL number of H.I. pred-succ pairs found = #{num_hi_pairs}"

g.close

# store the ahi array of historical instances
#File.open('ahi_dump.marshal', 'w'){|f|
#  Marshal.dump(ahi, f)
# }


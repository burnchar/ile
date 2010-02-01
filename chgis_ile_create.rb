#!/usr/bin/ruby
# Code to create ile version of v4 of Harvard's chgis

# By Vitit Kantabutra
# January 2010

require 'date' # probably not used
require 'dbset'
require 'tracer'

dbset_chgis = DatabaseSet.new("chgis in ILE",
"Set of 1 database of v4 chgis in ILE")

db_chgis = Database.new("chgis", "Database of v4 chgis in ILE", dbset_chgis)

# Listing all databases in dbset
dbset_chgis.print_db_names

# Make entity sets
# 1. Names in Pinyin, including types
ntp_es = EntitySet.new('names_types_py_es',
         :currentdb => db_chgis,
         :description => "All names, types in Pinyin",
         :keyattribnames => [:name_py, :type_py],
         :keyattribtypes => {:name_py => String, :type_py => String}
)

ntc_es = EntitySet.new('names_types_ch_es',
         :currentdb => db_chgis,
         :description => "All names, types in Chinese",
         :keyattribnames => [:name_ch, :type_ch],
         :keyattribtypes => {:name_ch => String, :type_ch => String}
)

# Now add the entities!!

CHHash = Hash.new # dictionary for Pinyin equiv of Chinese names
f = File.open 'v4_main_table_name_type_unique'
while l = f.gets
  # NOTE: Sometimes types are empty, and so these will be
  #       stored in a hash with nil key!!

  l.chomp!
  l =~ /^\s*(.*?)\,\s*(.*?)\,\s*(.*?)\,\s*(.*?)$/

  Entity.new(ntc_es, {:name_ch => $3, :type_ch => $4}, {})
  if ntp_es.hashofentities[$1] and ntp_es.hashofentities[$1][$2] 
    puts 'Already got this Pinyin name-type!' + $1 + ',' + $2
    CHHash[$1 + '*' + $2].push ntc_es.hashofentities[$3][$4]
  else
    Entity.new(ntp_es, {:name_py => $1, :type_py => $2}, {})
    CHHash[$1 + '*' + $2] = Array.new
    CHHash[$1 + '*' + $2].push ntc_es.hashofentities[$3][$4]
  end # if
end # while
f.close

# Define relset relating chinese and pinyin names
chpy_nametype_rs =
  Relset.new('chpy_nametype_rs',
             :currentdb => db_chgis,
             :description => 'Relating chinese to Pinyin (Romanized) names, where sometimes different Chinese names could translate to the same Pinyin character string because they are pronounced the same',
             :role_name_array => [:names_types_py, :names_types_ch],
             # could've been called name_ch because the Chinese name 
             # is unique for each relationship
             :role_desc_hash => # hash describing what's in each role
             {
               # these entities need no wrappers
               :names_types_py => 'names_types_py_es',
               :names_types_ch => 'names_types_ch_es'
             } # role desc hash
) # Relset.new

# Make the relationships relating Pinyin to Chinese names
# There may be more than one Chinese names per Pinyin name, but right now assume not vice versa
CHHash.each_pair{|k,v|
  # Get Pinyin name and type
  k =~ /(.*)\*(.*)/
  Relationship.new('chpy_nametype_rs',
                   {:names_types_py => ntp_es.hashofentities[$1][$2],
                     :names_types_ch => v
                   },{}, db_chgis
                   )
} # each_pair
# save database set
#dbset_chgis.saveDbset 'dbset_chgis.marshal'
# show database
# db_chgis.show

tracer = Tracer.new
tracer.add_filter lambda{|event, *rest| event == "call"}
tracer.on do
  chpy_nametype_rs.search({:names_types_py =>
                            {:spec_type => :key_single_value, 
                              :specs => ["Jianning Fu", "Fu"] # when the specs are just a single key value, we only need to input
                              # the key attributes in an array, with the understanding that those attributes are ordered correctly
                            }
                          },
                          nil)
end


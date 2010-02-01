#!/usr/bin/ruby
# encoding: utf-8
require 'date' # Could also just use Fixnum

# ILE database for CHGIS - just a small part of it

require 'dbset'

dbset_chgis = DatabaseSet.new("CHGIS dbset",
"Set of databases for CHGIS consisting of just one very small database right now")
db_CHGIS = Database.new("CHGIS", "Harvard CHGIS database redone in ILE", dbset_chgis)

# Listing all the databases in the dbset
dbset_chgis.print_db_names

# Make an entity set; let's make attrib names and types all symbols!! 

# Note: new idea: instead of a name, make it an array of names whose 
# elements are all the possible spellings.  To search, just have to match
# one of the spellings.  To be implemented later.  Right now we'll forget
# all the alternative spellings, or make them entities!

# ENTITY SETS
# 1. places, without names defined
places_es = EntitySet.new('places',
              :currentdb => db_chgis,
              :description => "places defined without their names",
              :keyattribnames => [:id_number],
              :keyattribtypes => {:id_number => Fixnum},
              :nonkeyattribnames => [:notes],
              :nonkeyattribtypes => {:notes => String}                          
)

pl1 = Entity.new(people_es, {:id_number => 90004}, {})

# 2. dates
dates_es = EntitySet.new('dates',
              :currentdb => db_chgis,
              # No description
              :keyattribnames => [:date],
              :keyattribtypes => {:date => Fixnum} # just the year
xs)

d1 = Entity.new(dates_es, {:date => Date.new(1368)}, {})
d2 = Entity.new(dates_es, {:date => Date.new(1455)}, {})
d3 = Entity.new(dates_es, {:date => Date.new(1734)}, {})
d4 = Entity.new(dates_es, {:date => Date.new(1911)}, {}}

# 3. Place Names
placenames_es = EntitySet.new('placenames',
              :currentdb => db_chgis,
              :description => 'names to be related to places as their placenames',
              :keyattribnames => [:placename],
              :keyattribtypes => {:placename => String}
)

pn1 = Entity.new(placenames_es, {:placename => 'Jianning Fu'}, {})

# Make a relationship set
transactions_rs = 
  Relset.new('transactions',
             :currentdb => db_Spain16,
             :description => 'commercial transactions',
             :role_name_array => ['merchants', 'clients', 'places', 'dates', 'hist sources'],
             :role_desc_hash => 
             {
               'merchants' => 
               {
                 :esname => 'people',
                 :attributes => {:is_present => [TrueClass, FalseClass]}
               },
               
               'clients' =>
               {
                 :esname => 'people',
                 :attributes => {:is_present => [TrueClass, FalseClass]}
               },
               
               'places' => 'places', # these entities need no wrappers, and also happen to have the
                                      # same entity set name as the role name

               'dates' => 'dates',
             
               'hist sources' => 'hist sources'
             },

             :attrtype_hash => {:trans_value => Fixnum,
               :trans_type => String,
               :trans_desc => String}
)

# MAKE THE ENTITY STRUCTS FOR THE MERCHANTS AND THE CLIENTS

entity_struct1 = EntityStruct.new
entity_struct1.entity = pe1  # Cavitello
entity_struct1.attr_hash = {:is_present => true}

entity_struct2 = EntityStruct.new
entity_struct2.entity = pe2  # Lita
entity_struct2.attr_hash = {:is_present => false}

entity_struct3 = EntityStruct.new
entity_struct3.entity = pe3  # del Rio
entity_struct3.attr_hash = {:is_present => true} # made up value, must verify

# hash of attributes for new relationship!!
r1_attr_hash = {:trans_value => 10285,
                :trans_type => 'soldada', 
                :trans_desc => 'Hire worker for lavaderos for year; pay 27.5 reales a month, with an advance of part of the pay of 2 ducados given to him by Borsio Cavitello; did not sign and witness who signed for him was Licenciado Oviedo, vecino Cuenca; other two witnesses were Licenciado Moya and Alonso de lavacio (?)'}

# Finally make a relationship in this set!!
r1 = Relationship.new('transactions', 
                      {'merchants' => [entity_struct1, entity_struct2],
                       'clients' => entity_struct3,
                        'dates' => d1,
                        'places' => pl1,
                        'hist sources' => hs1
                      },
                      r1_attr_hash,
                      db_Spain16
)

puts 'Now call show database'
db_Spain16.show

# Save database
dbset_owens.saveDbset 'dbset_owens.marshal'
 
# QUERY database using relset's query function
transactions_rs.show_related_entities({'merchants' =>  pe1, 'dates' => d1},
                                      ['clients', 'hist sources'])
                                      

#!/usr/bin/ruby
# encoding: utf-8
require 'date'

# ILE database for Owens' 16th century Spain merchant network.

require 'dbset'


dbset_owens = DatabaseSet.new("Jack Owens' dbset",
"Set of databases for Jack Owens' projects")
db_Spain16 = Database.new("Spain16", "Database of 16th Century Spanish Merchant Network", dbset_owens)

# Listing all the databases in the dbset
dbset_owens.print_db_names


# Make an entity set; let's make attrib names and types all symbols!! 

# Note: new idea: instead of a name, make it an array of names whose 
# elements are all the possible spellings.  To search, just have to match
# one of the spellings.  To be implemented later.  Right now we'll forget
# all the alternative spellings, or make them entities!

# ENTITY SETS
# 1. people
people_es = EntitySet.new('people',
              :currentdb => db_Spain16,
              :description => "The people, both merchants and clients",
              :keyattribnames => [:surname, :firstname],
              :keyattribtypes => {:firstname => String, :surname => String},
              :nonkeyattribnames => [:personaltitle, :proftitle],
              :nonkeyattribtypes => {:personaltitle => String, :proftitle => String}
)

pe1 = Entity.new(people_es, {:surname => 'Cavitello', :firstname => 'Borsio'}, 
           {:personaltitle => "se\u{C3B1}or"})
pe2 = Entity.new(people_es, {:surname => 'Lita', :firstname => "Agust\u{C4BA}n"},
           {:personaltitle => "se\u{C3B1}or"})
pe3 = Entity.new(people_es, {:surname => "Del R\u{C48A}o", :firstname => "Juan"},
           {})


# 2. places
places_es = EntitySet.new('places', # esname is used as hash key in database object
# Why not change that (esname) to symbol?
              :currentdb => db_Spain16,
              :description => "Places, mostly cities",
              :keyattribnames => [:modern_muni_name],
              :keyattribtypes => {:modern_muni_name => String,},
              :nonkeyattribnames => [:longitude, :latitude, :zero_meridian],
              :nonkeyattribtypes =>{:longitude => Float,:latitude => Float,
                           :altitude => [Float, Fixnum], :zero_meridian => String}
)
                         
pl1 = Entity.new(places_es, {:modern_muni_name => 'Cuenca'},
                 {:zero_meridian => 'Royal Observatory, Greenwich',
                   :latitude => 40.08, :longitude => -2.14, :altitude => 990}
)

pl2 = Entity.new(places_es, {:modern_muni_name => 'Valladolid'},
                 {:zero_meridian => 'Royal Observatory, Greenwich',
                   :latitude => 41.65, :longitude => -4.74, :altitude => 710}
)

dates_es = EntitySet.new('dates',
              :currentdb => db_Spain16,
              # No description
              :keyattribnames => [:date],
              :keyattribtypes => {:date => Date}
)

d1 = Entity.new(dates_es, {:date => Date.new(1559, 2, 16)}, {})
d2 = Entity.new(dates_es, {:date => Date.new(1559, 3, 8)}, {})

hs_es = EntitySet.new('hist sources',
              :currentdb => db_Spain16,
              :description => 'these are the contracts',
              :keyattribnames => [:hs_name, :hs_folio],
              :keyattribtypes => {:hs_name => String, :hs_folio => String},
              :nonkeyattribnames => [:explanation],
              :nonkeyattribtypes => {:explanation => String}
)

hs1 = Entity.new(hs_es, {:hs_name => 'AHPC_P-170', :hs_folio => '117r-117v'},
 {}
)

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
                                      

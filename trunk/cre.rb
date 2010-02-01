# cre - create a relationship object
# syntax: 
# cre relsetname |||| 
# key of role 0 entity 0 | attrname = value | ... | attrname = value || role 0 entity 1 | ... || role 0 entity 2.... |||
# .....
# key of role n-1 entity 0 | attrname = value | .... | attrname = value | role n-1 entity 1 | ...  | role n-1 entity 2....

# [|||| relattrname = value | ... | relattrname = value]

def cre args, currentdb
  args.strip!
  relsetname, entity_string, attributes = args.split(/\s*\|\|\|\|\s*/)
  puts '***** cre called with relsetname = ' + relsetname
  puts 'string specifying the entities = ' + entity_string
  (puts 'string specifying the attributes = ' + attributes) if attributes
  puts 'NO RELATIONSHIP ATTRIBUTES' if not attributes
  
  entity_array_of_one_role_strings = entity_string.split(/\s*\|\|\|\s*/)
  entity_text_2D_array = Array.new # 2D array where each element of the outer array is an array of strings
  # describing all the entities in each role.  That is, each index value of the outer array pertains to 1 role
  entity_array = Array.new # also a 2D array where each index value of the outer array pertains to 1 role.  However,
  # each element of this array is no longer a string, but a Struct 'EAStruct' containing the entity and a attrib hash.

  relset = currentdb.hrs[relsetname]
  if not relset
    puts '!!!!!! CAN NOT DO THE cre COMMAND!! THE SPECIFIED RELATIONSHIP SET DOES NOT EXIST!!!!!!!'
    return nil
  end # if no such relset

  es_array = relset.es_array


  # define Entity-Attribute Struct or "EAStruct:, a Struct that contains one entity and a Hash of 
  #   "entity-relationship attributes"

  entity_Struct_2D_array = Array.new # 2D array each of whose element [i][j] is the jth entity playing role i
  entity_array_of_one_role_strings.each_with_index{|s, i|
    entity_Struct_2D_array[i] = Array.new
    # This is role i, so get the entity set reference for the entities playing role i
    # First get the relset object reference:
    puts '******* Current relset name = ' + relsetname
  
 
    es = es_array[i]

    entity_text_2D_array[i] = s.split(/\s*\|\|\s*/) # each element of this 2D array is a STRING representation of
                                       # 1 entity out of possibly several entities that play 1 role.
    # So make each such element into a Struct that has an entity and a Hash of attributes
    entity_text_2D_array[i].each{|e| # for each string representing an entity in role i
      puts "*****Processing an entity in role " + i.to_s
      esplit = e.split(/\s*\|\s*/)
      entity_key = esplit.shift # esplit is now either an empty array or an array with each element being 'name = value'
      # make attribute hash for entity-relationship attributes
      er_attrhash = Hash.new
      esplit.each{|esp|
        name,value = esp.split(/\s*=\s*/)
        er_attrhash[name] = value

        # if the type is a numeric type, let's store them as numbers later.  BUT NOW STORE THEM AS CHARACTER STRINGS for simplicity.

      }

      # Have to find the entity set that this entity belongs to; must look in RELATIONSHIP SET for that information
      # so that we know where to find the reference to the entity
      # When looking in relationship set, look for who is the entity set for role i
      es = relset.es_array[i]
      puts '***** Just set es to ' + es.inspect
      esref = currentdb.hes[es.esname]
      # Now pack up a struct comprising the entity reference and er_attrhash
      # es is a struct of type ESStruct, so must get the :esname component of it.  Actually this component
      # should've been defined as a ref to the entityset, not the esname.  However, we'll let it be for now.
      entity_Struct_2D_array[i] << Struct::EAStruct.new(esref.hashofentities[entity_key], er_attrhash)
      
    }  


  }

  # Now prepare to make a new Relationship object
  # the initializer of Relationship objects takes these params: 
  #      (relsetname, entitykeys, attribhash, currentdb)
  # We already have the first, second, and the fourth parameters; just have to
  # make up the third parameter into Hash form!
  attribhash = nil
  if attributes
    # would be nice to check for invalid format here!!
    # Here's a crude check to make sure the user knows to use double vertical bars
    if attributes.match(/\|/) and not attributes.match(/\|\|/)
      puts 'Use || to separate different attributes!'
      return nil
    end # if invalid separator
    attr_nv_pairs = attributes.split(/\s*\|\|\s*/)
    attr_nv_pairs.each{|nvp|
      n, v = nvp.split(/\s*=\s*/)
      attribhash[n] = v
    }
  end # if attributes is not nil
  # Finally call constructor of Relationship!
  newrel = Relationship.new(relsetname, entity_Struct_2D_array, attribhash, currentdb)
  # And install the new relationship in its relationshipset
  currentdb.hrs[relsetname].relarray = newrel
end # def cre


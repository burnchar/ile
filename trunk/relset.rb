# relset.rb, defines the relationship set class
# Initializer takes an array of role names (in order of roles taken in the
# relationships of the relationship set), a hash roles_desc_hash
# that describes what entity set the ENTITIES belong to, as well as PER-ENTITY RELATIONSHIP
# ATTRIBUTES (if any) corresponding to each role name,
# and arrays of relationship attribute
# names and types, if any, and a ref to the current db

# Further clarification on roles_desc_hash:
# roles_desc_hash[rolename][:esname] = entity set name for entities playing role
#    named by rolename
# roles_desc_hash[rolename][:attributes] = a hash that hashes the per-entity relationship
#    attribute names to their classes!

class Relset

  def initialize(relsetname, params)
    # Keep an array of entity set references, sorted by role starting with
    # role 0.
    @relsetname = relsetname
    @currentdb = params[:currentdb] # reference to current database, not database name
    @description = params[:description]
    @role_name_array = params[:role_name_array]
    @role_desc_hash = params[:role_desc_hash]
    @attrtype_hash = params[:attrtype_hash]

    # Finally, an Array of references to all the relationships in this relset!
    @relarray = Array.new # change to hash?  But hash by what?
    
    # install this Relset in current db
    @currentdb.hrs[@relsetname] = self

    puts '***Just created the following RELSET:'
    puts '@relsetname = ' + @relsetname.inspect
    puts '@role_name_array = ' + @role_name_array.inspect
    puts '@role_desc_hash = ' + @role_desc_hash.inspect
    puts '@attrtype_hash = ' + @attrtype_hash.inspect                              

  end # initialize

  def show # trivial version, to be edited
    puts "Showing RELATIONSHIP SET with name: #{@relsetname}"
    puts "The roles are:"
    @role_name_array.each{|r|
      puts "    #{r}"
    } # each
    puts "The RELATIONSHIPS in this relset:"
    @relarray.each{|ra|
      ra.show
    }
    puts 'END OF SHOWING OF A RELATIONSHIP SET'
  end # show

# QUERIES!!

  # The following utility routine makes an array of entities out of either a single entity or a
  # single entity struct, or an Array each of whose elements is either of those, into an array of
  # references to Entities.  Note that we won't be making new entities, just new pointers.
  def make_entity_array x
    retval = Array.new
    case x.class.to_s
    when 'Entity'
      retval.push x
    when 'EntityStruct'
      retval.push x.entity
    when 'Array'
      x.each{|elem|
        if elem.class.to_s == 'Entity'
          retval.push elem
        elsif elem.class.to_s == 'EntityStruct'
          retval.push elem.entity
        else
          puts "ERROR elem.class invalid, is #{elem.class}"
        end # if
      } # x.each
    else
      puts "ERROR: input class invalid, is #{x.class}"
      exit
    end # case
    return retval
  end # make_entity_array

# Search method! In this version, only simple assertions involving each each role separately are permitted.  This is
# not a limitation of the data structure, but of the structure of this code and the simple parsing that permits on
# one mention of an attribute, which must occur at the beginning of the expression, such as entityset.attribute < 5.

# INPUT: (1) hash of entities hashed by role names (2) array of names of roles whose entities are to be output
#  We must have a way to specify the input roles!  For each role, we must be able to specify, if we want to do so,
#  (a) how many entities there are in each role,
#  (b) restrictions on the existence and values of the attributes in the entities
#  So the input is a hash, keyed by the role names. Each element (hash value) is itself a hash,
#  allowing us to specify the properties of the entities mentioned in (a) and (b) above.

# Example of input specification, that is, (1)
#   In chgis, the relationship place-name(place, name-ch, begin-time-array, end-time-array) says that a placed is name with
#   a certain name (in Chinese) in the periods begin-name-array[i] - end-name-array[i], for all i.
#   One possible query would be to specify place and a year, and see what name was used to mean that place during that year.

# OUTPUT RETURNED: hash of entities that are in the roles whose names are specified in item (2) in the input

  def search(roles_in, roles_out)

# roles_in is a hash, keyed by the role names. Each hash value is the specifications for that role.  These specs say, for
# example, what values the attributes of each entity in that role must have for that entity to play that role in the
# relationship.  In general, these specs can be complicated, but for now (Jan 2010) we'll limit ourselves to simple
# specs.

# For now 3 types of specs are allowed, :key_single_value, :key_range, and :general.

# Meaning (if quantifier for roles_in is :all for every input role): for every relationship in this relset such that
# all the entities in the input roles satisfy the given constraints, output the entities in the roles_out specs.
# For simplicity just allow 1 constraint, at most, per role right now!! To be generalized, of course.

    # Need a place to accumulate relationship objects
    relationships = Array.new

    first_role_considered = true
    roles_in.each_pair{|role_name, role_specs|
      # for each role, compute the entity set name and the entity set
      puts 'Processing role ' + role_name.to_s
      puts '@role_desc_hash is ' + @role_desc_hash.inspect
      esname = @role_desc_hash[role_name]
      puts 'esname = ' + esname
      es = @currentdb.hes[esname]
      if role_specs[:spec_type] == :key_single_value # single key value, but of course each key attrib must have a value
        if role_specs[:specs].class != Array # single spec
          puts 'Single spec for this role, which means KEY must have SINGLE ATTRIBUTE'
          puts 'Put it in an array of length 1 and proceed!'
          givenspecs = role_specs[:specs]
          role_specs[:specs] = Array.new
          role_specs[:specs].push givenspecs
        end
        # Now get to the entity based on the given key
        # Must first parse the given array elements for the key attributes!
        numkeys = @currentdb.hes[esname].keyattribnames.size
        puts "number of key attributes is #{numkeys}"
        if role_specs[:specs].size != numkeys
          puts "ACHTUNG: size of role specs, #{role_specs[:specs].size}, is not equal to number of key attributes, quitting"
          exit
        end
        
        # Find the entity keyed by the given key attributes, and find the array of all relationships in the relevant relset (self)
        # with this entity serving in this role!
        entity = es.hashofentities # entity will eventually refer to the entity keyed by the given attribute values
        role_specs[:specs].each{|spec|    # the specs are just the values of the key attributes
          puts "Processing spec = #{spec.to_s}"
          entity = entity[spec]
          puts "entity just became #{entity.to_s}"
        } # each
        # ensure that the variable 'entity' points to an entity!
        puts "Arrived at this entity: #{entity.to_s}"    
        if entity.class != Entity
          puts "Something's wrong! The variable called entity points to an object of class #{entity.class.to_s}"
          exit
        end # if, inner
        if first_role_considered
          first_role_considered = false
          if entity.relationships[self].class == Array
            puts 'Inaugurating the relationships array!'
            relationships = entity.relationships[self]
          else
            puts 'First role considered but entity.relationships[self] is not an Array'
            relationships.push (entity.relationships[self])
          end # if, inner
        
          puts "Just made relationships array = #{relationships.to_s}"
        else
          puts 'Must correct this part of the code because either operand of the & operator may not be an Array!'
          relationships = relationships & entity.relationships[self] # intersect existing relationship set (Array) with incoming one
          puts "Hey, just made relationships array = #{relationships.to_s}"
        end # if, inner

      else
        puts 'Role type not yet implemented, sorry!'
        exit
      end # if
      
    } # role_in.each_pair
    
    # Now do something with the relationship set obtained!!!
    puts 'Will have the code the part where we look at the output specs LATER!!'
    puts 'For now, here are the relationships obtained:'
    relationships.each_with_index{|r,i|
      puts "Relationship number #{i}:"
      r.show
    }
  end # def search
  attr_accessor :relsetname, :role_name_array, :es_hash, :attrtype_hash, :relarray
end # class Relset

# Permit entities without wrappers (entity structs) to be
# entered into a relationship where a wrapper is unnecessary.  Also possible to not require
# arrays where a single entity is needed for a role.  These ideas work because the program
# can just check the class of the entries whether it is an array, a wrapper, or an entity.

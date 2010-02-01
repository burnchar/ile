# relationship.rb, defining the Relationship class
# Takes 4 arguments. The first is the name of the relationship set
# to which this relationship belongs.
 
# The second parameter represents all the entities tha play the various roles
# in the relationship.  A hash is appropriate to represent these entities,
# where we use each role name (which may be a symbol) as the hash index,
# indexing into entities OR an array of entities (in case there are more
# than one!!)

# But what object should we use to represent each entity?  
# Often just the entity itself suffices, in case only one entity plays that
# role and there are no per-entity attributes.

# In case there are more than one entity serving in the same role, then they can 
# all go into an array.

# Lastly, consider the case in which there are per-entity relationship attributes.
# Then each entity must be wrapped in an ENTITY STRUCT.

# Here is the definition of this struct.
# AN ENTITY STRUCT IS LIKE A WRAPPER FOR AN ENTITY, containing not only an entity
# but also its per-entity relationship attributes.
EntityStruct = Struct.new(:entity, :attr_hash)

class Relationship
  def initialize(relsetname, hash_of_roles, attribhash, currentdb)
    @relset = currentdb.hrs[relsetname]
    @currentdb = currentdb
    @attribhash = attribhash # 'static' relationship attributes, not the per-entity ones
     
    # check to make sure all the hash keys are legitimate role name (symbols)
    # according to the definition in the relset
    # Note that we aren't checking whether each entity is of the proper class or not!!
    hash_of_roles.keys.each {|k|
      if !(@relset.role_name_array.member? k)
        puts 'Incoming relationship has an ILLIGITIMATE role :' + k.to_s
        exit
      end # if

      # Now record this relationship in each entity's "@relationships" field
      e = hash_of_roles[k]
      # if e is just one entity, then see if any relationship from this relset has ever
      # been recorded with that entity.  If not, record it there.  If so, see if what's
      # recorded is an array or a relationship.  If an array, just put this new relationship
      # there.  If a relationship, replace it with an array that now has 2 relationships in it,
      # namely, the one that was there before and the new one
   
      if e.class == Entity or e.class == EntityStruct
        # Strip the Struct if we have one
        if e.class == EntityStruct
          e = e.entity
        end # if, inner
        # no relationship of this relset recorded before in that entity
        if !(e.relationships[@relset]) 
          e.relationships[@relset] = self
        elsif e.relationships[@relset].class == Array
          e.relationships[@relset].push self
        elsif e.relationships[@relset].class == Relationship
          old_rel = e.relationships[@relset]
          e.relationships[@relset] = Array.new
          e.relationships[@relset].push old_rel
          e.relationships[@relset].push self
        else
          puts 'ERROR in relationship.rb: e.relationships[@relset] is neither an Array nor a Relationship!!!'
          exit
        end # if, inner
      elsif e.class == Array
        # Then process each one, which should be an Entity or EntityStruct!
        e.each{|e1|
          if e1.class == EntityStruct
            e1 = e1.entity
          end # if, inner
          # no relationship of this relset recorded before in that entity
          if !(e1.relationships[@relset]) 
            e1.relationships[@relset] = self
          elsif e1.relationships[@relset].class == Array
            e1.relationships[@relset].push self
          elsif e1.relationships[@relset].class == Relationship
            old_rel = e.relationships[@relset]
            e1.relationships[@relset] = Array.new
            e1.relationships[@relset].push old_rel
            e1.relationships[@relset].push self
          else
            puts 'ERROR in relationship.rb: e1.relationships[@relset] is neither an Array nor a Relationship!!!'
            exit
          end # if, inner

        } # e.each
      else
        puts 'ERROR in relationship.rb: e.class is neither Entity nor Array!'
        exit
      end # if, outer
      }

    # puts 'PASSED the role name legitimacy test'
    # puts 'NOT testing whether or not the role entries are legitimate at this time'
    @hash_of_roles = hash_of_roles
# Now check if all the static attributes are of the right names
    if @relset.attrtype_hash
      static_attrtype_hash_relset_keys = @relset.attrtype_hash.keys
      attribhash.each_key{|k|
        if static_attrtype_hash_relset_keys.member? k
          puts "Static attribute key #{k.to_s} is valid"
        else
          puts "ERROR: Static attribute key #{k.to_s} is NOT valid!!"
          exit
        end
      }
    end # if attribhash (if there are attributes)
  
    # FINALLY, if everything appears to be OK, then INSTALL this relationship into
    # the relset!!
    @relset.relarray.push self
  end # def initialize

  def show
    puts 'SHOWING A RELATIONSHIP'
    puts 'Hash of Roles:'
    @hash_of_roles.each_pair do |k,v|
      puts "  * Role name: #{k}"
      c1 = v.class
      puts "    The class of the entry is: #{c1.to_s}"
      if c1 == Entity
        puts "       The Entry is an ENTITY of the Entity set named #{v.es.esname}"
        puts "       The KEY ATTRIBUTES:"
        v.hashofkeys.each_pair{|k,v|
          puts "          #{k.to_s}\t#{v.to_s}"
        }
      elsif c1 == EntityStruct
        puts "       The Entry is an ENTITY STRUCT with the following parts:"
        puts "       (1) An ENTITY of the Entity set named #{v.entity.es.esname}"
        puts "       with the KEY ATTRIBUTES:"
        v.entity.hashofkeys.each_pair{|k,v|
          puts "          #{k.to_s}\t#{v.to_s}"
        }
        puts "       and with the NON-KEY ATTRIBUTES (if any):"
        v.entity.hashofnonkeys.each_pair{|k,v|
          puts "          #{k.to_s}\t#{v.to_s}"
        }
        puts "       (2) PER-ENTITY ATTRIBUTES given by the following hash:"
        v.attr_hash.each_pair{|k,v|
          puts "          #{k.to_s}\t#{v.to_s}"
        }

      elsif c1 == Array
        v.each{|x|
          puts '      Here is an array element:'
          if x.class == Entity
            puts "       It's an ENTITY of the Entity set named #{x.es.esname}"
            print "        "
            x.show
          elsif x.class == EntityStruct
            puts "       IT's an ENTITY STRUCT with the following parts:"
            puts "       (1) An ENTITY of the Entity set named #{x.entity.es.esname}"
            puts "       with the KEY ATTRIBUTES:"
            x.entity.hashofkeys.each_pair{|k,v|
              puts "          #{k.to_s}\t#{v.to_s}"
            }
            puts "       and with the NON-KEY ATTRIBUTES (if any):"
            x.entity.hashofnonkeys.each_pair{|k,v|
              puts "          #{k.to_s}\t#{v.to_s}"
            }
            puts "       (2) PER-ENTITY ATTRIBUTES given by the following hash:"
            x.attr_hash.each_pair{|k,v|
              puts "          #{k.to_s}\t#{v.to_s}"
            }
          else
            puts "***ERROR*** unknown class"
            exit
          end   
        }
      end # if

    end # each_pair
    puts 'END SHOWING A RELATIONSHIP'
  end # show

  attr_accessor :relsetname, :hash_of_roles, :attribhash, :currentdb
end # class Relationship

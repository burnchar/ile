# OLD VERSION of relationship.rb, defining the Relationship class
# Takes 4 arguments. The first is the name of the relationship set
# that this relationship belongs to. 
# The second is an Array of Arrays of Struct, each having an entity key and a Hash of
#    zero or more attributes that are attached to that entity and not to the whole
#    relationship.
# sorted by their roles (at the outer level of Array).
# The third is a hash of relationship attributes
# as a comma separated list of name = value.  Note that strings
# must be double-quoted.  If the relationship has any attributes then
# the attributes part is separated from the array of entity keys by a
# semicolon.  The fourth parameter is a ref to the current
# database. 


# Remember to put this relationship in all the entities as well.  There,
# We also have to record the role(s) that the entity plays in the relationship.

# MUST REWRITE parts that have to do with the second argument.  It's now a 2D
# array of structs.  Before it was an array of entities.

class Relationship
  def initialize(relsetname, entity_Struct_2D_array, attribhash, currentdb)
    @relset = currentdb.hrs[relsetname]
    @attribhash = attribhash
    # We'll keep an array of arrays of references to Structs, where each Struct
    #    has an entity and a hash containing its attributes just for this relation.
    #    These attributes are not the entity's "permanent" attributes.  They are
    #    just attributes that pertain to this relationship.

    # Wonder if this free typing is good for the "permenent" attributes too?
    @entity_Struct_2D_array = entity_Struct_2D_array
    
  end # def initialize
  attr_reader :relset, :entityrefs_array
end # class Relationship

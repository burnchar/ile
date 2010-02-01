# entityset.rb, defining the EntitySet class
# old version, no hashed parameters

class EntitySet
  def initialize esname, description, keyattribnames, keyattribtypes,
                 nonkeyattribnames, nonkeyattribtypes, currentdb

    @esname = esname.clone # a String
    @description = description.clone # a string

    @keyattribnames = keyattribnames.clone   # an Array
    @keyattribtypes = keyattribtypes.clone   # a Hash

    if nonkeyattribnames
      @nonkeyattribnames = nonkeyattribnames.clone  # an Array
      @nonkeyattribtypes = nonkeyattribtypes.clone  # a Hash
    end
    # Hash of all entity structs in this entity set
    @hashofentities = Hash.new

    # Each entity set has a Hash of all relationship sets in which the entities of
    # the entity set is involved in.  Should we also store info on which role(s) the
    # entities in this entity set are involved in?  May be nice to do that.
    # For now, just make a new Hash

    @hrs = Hash.new
    @currentdb = currentdb

# MUST attach this entity set to the current database's @hes
    @currentdb.hes[@esname] = self

  end # def initialize

  def show # called by database.show
    puts '*** entity set name, @esname = ' + @esname
    puts '*** entity set description = ' + @description
    puts '*** key attrib names ='
    @keyattribnames.each{|x|
      puts 'key name: ' + x.inspect + '  ' + 'type: ' + @keyattribtypes[x].inspect
    }
    puts
    if @nonkeyattribnames
      puts '*** non-key attrib names ='
      @nonkeyattribnames.each{|x|
        puts 'non-key name: ' + x.inspect + '  ' +
        'type: ' + @nonkeyattribtypes[x].inspect
      }
    end # if
    puts

    puts 'STILL HAVE TO PUT CODE IN TO PRINT OUT THE ENTITIES..............'

  end # show

  attr_reader :esname, :keyattribnames, :keyattribtypes,
  :nonkeyattribnames, :nonkeyattribtypes, :hashofentities, :hashofrelsets
  attr_writer :esname, :keyattribnames, :keyattribtypes,
  :nonkeyattribnames, :nonkeyattribtypes, :hashofentities, :hashofrelsets
end # class EntitySet


# entityset.rb, defining the EntitySet class

# first parameter: entity set name
# hash parameters:
#   :description  -  a string
#   :keyattribnames - an array of key attrib names in order
#   :Keyattribtypes - a hash of key attrib types hashed by key attrib names
#   :nonkeyattribnames - an array of non-key attrib names in order
#   :nonkeyattribtypes - a hash of non-key attrib types hashed by names
#   :currentdb - a reference to the database to insert entity set into

class EntitySet
 # def initialize esname, description, keyattribnames, keyattribtypes,
 #                nonkeyattribnames, nonkeyattribtypes, currentdb
  def initialize (esname, params)
    @currentdb = params[:currentdb]
    @esname = esname.clone # a String
    if params[:description]
      @description = params[:description].clone # a string
    end # if there's a description string

    @keyattribnames = params[:keyattribnames].clone   # an Array
    @keyattribtypes = params[:keyattribtypes].clone   # a Hash
    
    if params[:nonkeyattribnames]
      @nonkeyattribnames = params[:nonkeyattribnames].clone  # an Array
      @nonkeyattribtypes = params[:nonkeyattribtypes].clone  # a Hash
    end
    # Hash of all entity structs in this entity set
    # Let's make it a multidimensional hash! The outer level is
    # hashed by the first attribute, etc.  The initializer of the 
    # Entity class will do the hashing
    @hashofentities = Hash.new

    # Each entity set has a Hash of all relationship sets in which the entities of
    # the entity set is involved in.  Should we also store info on which role(s) the
    # entities in this entity set are involved in?  May be nice to do that.
    # For now, just make a new Hash

    @hrs = Hash.new
    

# MUST attach this entity set to the current database's @hes
    @currentdb.hes[@esname] = self

  end # def initialize

  def show # called by database.show
    puts '*** entity set name, @esname = ' + @esname
    if @description
      puts '*** entity set description = ' + @description
    end # if there's a description string
    puts '*** key attrib names ='
    @keyattribnames.each{|x|
      print '>>>>>key name = ' 
      print x.inspect 
      print '  type = ' 
      puts @keyattribtypes[x].inspect
    }
    puts
    if @nonkeyattribnames
      puts '*** non-key attrib names ='
      @nonkeyattribnames.each{|x|
        puts '>>>>>non-key name = ' + x.inspect + '  ' +
        'type = ' + @nonkeyattribtypes[x].inspect
      }
    end # if
    puts

    puts 'Entities, if any...'

    # puts 'Outer level keys of hash of entities are '
    # @hashofentities.each_key{|k| puts k}

    currenthash = @hashofentities

    # puts "For entity set = #{@esname}, DEPTH-FIRST SEARCH OF DEEP HASH OF ENTITIES!!"
    if @hashofentities.size > 0
      dfs @hashofentities
    else
      puts 'No entities in this entity set to show!!'
    end # if

  end # show

  def dfs hash
    hash.each_pair{|i,v|
      # puts 'Hash key = ' + i.to_s
      if v.class == Hash
        # puts 'Value is a Hash! Dig down.'
        dfs v
      else
        # puts 'Value is not a Hash'
        # puts 'But is ' + v.to_s
        if v.class == Entity
          puts 'Found an entity with attributes... '
          v.show_attributes
        end
      end # if
    }
  end # def dfs


  attr_reader :esname, :keyattribnames, :keyattribtypes,
  :nonkeyattribnames, :nonkeyattribtypes, :hashofentities, :hashofrelsets
  attr_writer :esname, :keyattribnames, :keyattribtypes,
  :nonkeyattribnames, :nonkeyattribtypes, :hashofentities, :hashofrelsets
end # class EntitySet


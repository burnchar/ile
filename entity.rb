# entity.rb, defining the Entity class
# 

class Entity
  def initialize (es, hashofkeys, hashofnonkeys)
    # First make sure that the hashes don't have any nil keys!
    hashofkeys.each_key{|k|
      if k == nil
        puts 'ERROR: hash of keys has a nil key!'
        exit
      end
    }
    hashofnonkeys.each_key{|k|
      if k == nil
        puts 'ERROR: hash of non-keys has a nil key!'
        exit
      end
    }
    # puts 'Making Entity ' + self.to_s
    # Later on it would be nicer to have the user input esname and dbname
    # instead of an es reference!
    @es = es # reference to entity set to which this entity will be installed
    @hashofkeys = hashofkeys.clone        #hopefully this is shallow cloning
    @hashofnonkeys = hashofnonkeys.clone
    # INSTALL this entity into es's hash of entities.
    # Let's make it a multidimensional hash! The outer level is
    # hashed by the first attribute, etc. 
    # We need the ordering of the keys from the entity set
    currentHash = es.hashofentities # current level of hash
    #puts 'Current hash of entities = ' + currentHash.inspect

    es.keyattribnames.each_with_index{|v,i|
      #puts 'Now considering key attrib with name ' + v.to_s
      # so long as this is not the last key, then 
      if i < (es.keyattribnames.size) - 1
        #puts 'Using hash key = ' + hashofkeys[v].to_s
        if currentHash[hashofkeys[v]] == nil
          currentHash[hashofkeys[v]] = Hash.new # build up hash if needed
          #puts 'Just made another level of hash'
        end # if
        currentHash = currentHash[hashofkeys[v]] # and advance to next
        # nesting level
      else # innermost hash level
        #puts 'Using hash key ' + hashofkeys[v].to_s + ' at inner level'
        # for simplicity just overwrite entity if there's one there!
        currentHash[hashofkeys[v]] = self # install entity!!
      end # if-else
    }

    @relationships = Hash.new
    # all relationships in which this entity is involved
    # Hash key is relationship set name

    # (Note: each entity can participate in several relationships in the
    #  same relationship set, and in multiple roles in the same relationship as well.)

    # Question: how to deal with case where this entity
    # plays multiple roles in a relationship?  Should
    # we record which role(s) the entity plays?
    
    # Here's how to deal with this: store a hash of hashes
    # of arrays of relationship references
    
    # @relationship["relset1"][0] would be an Array of references to all
    # the relationships of the relset named "relset1", where this entity
    # play role 0.

  end # initialize

  def show
    show_attributes
  end

  def show_attributes
    print "KEY values: "
    @es.keyattribnames.each{|k|
      print hashofkeys[k].to_s + '  '
    }
    puts
    if @es.nonkeyattribnames
      print "NON-KEY values: "
      @es.nonkeyattribnames.each{|nk|
        print hashofnonkeys[nk].to_s + '  '
      }
      puts
    end # if there are non-keys
  end # show_attributes

  attr_accessor :es, :hashofkeys, :hashofnonkeys, :relationships
end # class Entity


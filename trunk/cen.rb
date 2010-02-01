# cen: create an entity
# syntax: cen esname ||| attrib1 = value1 || .... || attribn = valuen
# Attributes can be specified in any order.  Unspecified ones will be nil.
# 
  # integer: an optional - or + sign, followed by one or more digits,
  # real: an optional sign, one or more digits (no -.5), followed
# String: can be input with or without quotes.  If without, then all blanks
# at the beginning and at the end will be removed. If with quotes, then 
# the quotes will be removed

def cen (args, currentdb)
  puts 'cen command read with argument string = ' + args
#  puts '    and currentdb = ' + currentdb.to_s
#  puts '    currentdb.hes = ' + currentdb.hes.inspect

  # integer: an optional - or + sign, followed by one or more digits,
  #     followed by an optional exponent with an optional + sign. (no - exp)
  int_regexpstr = '^[-+]?\d+([eE]+?\d+)$?'

  # real: an optional sign, one or more digits (no -.5), followed
  # by a decimal point, and one or more digits
  # This is then followed by an optional exponent part.
  real_regexpstr = '^[-+]?\d+\.\d+([eE][-+]?\d+)?$'

  args.strip! 
  args_array = args.split(/\s*\|\|\|\s*/)

  esname = args_array[0]
  attribstring = args_array[1]
  if not args_array[0]
    puts 'ERROR: no entity set name in entity creation command, cen'
    return nil
  elsif not args_array[1]
    puts 'ERROR: no attributes in entity creation command, cen'
    return nil
  end # if error
  attribarray = attribstring.split(/\s*\|\|\s*/)

  puts 'esname = ' + esname
  puts 'attributes = ...'
  attribarray.each{|a|
    puts a
  }
  
  # Make a hash of attributes where the values are still strings, uninterpreted
  attribhash_uninterpreted = Hash.new
  attribarray.each{|a|
    key,value_as_string = a.split(/\s*=\s*/)
    attribhash_uninterpreted[key] = value_as_string
  }

  # Get a reference to the entity set where we'll install this entity
  currentes = currentdb.hes[esname]
  puts 'currentes = ' + currentes.to_s

  # define hashes of key and nonkey attributes
  hashofkeys = Hash.new
  hashofnonkeys = Hash.new

  # keys
  currentes.keyattribnames.each_with_index{|k,i|

    value_as_string = attribhash_uninterpreted[k]
    if currentes.keyattribtypes[i] == 'text'
      # if enveloped in single or double quotes, remove the ones at the beginning and end
      if value_as_string.match(/^\"(.*)\"$/)
        hashofkeys[k] = $1
      elsif  value_as_string.match(/^'(.*)'$/)
        hashofkeys[k] = $1
      else
        hashofkeys[k] = value_as_string
      end # if, inner
    elsif currentes.keyattribtype[i] == 'number'
      value_as_string.gsub!(/\s/, '') # get rid of blanks
      if value_as_string =~ /\./ or value_as_string =~ /[eE]-/
        hashofkeys[k] = value_as_string.to_f
        puts 'String ' + value_as_string + ' converted to FLOAT with value ' + hashofkeys[k].to_s
      else
        hashofkeys[k] = value_as_string.to_i
        puts 'String ' + value_as_string + ' converted to INT with value ' + hashofkeys[k].to_s
      end # if (different numerical types)
    else
      puts 'INVALID ATTRIBUTE TYPE: ' + currentes.keyattribtype[i]
      return nil
    end # if, outer
  }

  # Make sure all key values are present
  currentes.keyattribnames.each{|k|
    if not hashofkeys.has_key?(k)
      puts '*****Key attribute missing: ' + k
      return nil
    end # if key attribute missing
  }
  # nonkeys
  if currentes.nonkeyattribnames
    currentes.nonkeyattribnames.each_with_index{|nk,i|
      if (value_as_string = attribhash_uninterpreted[nk])
        puts 'READ non-key value as string = ' + value_as_string
        if currentes.nonkeyattribtypes[i] == 'text'
          # if enveloped in single or double quotes, remove the ones at the beginning and end
          if value_as_string.match(/^\"(.*)\"$/)
            hashofnonkeys[nk] = $1      elsif  value_as_string.match(/^'(.*)'$/)
            hashofnonkeys[nk] = $1
          else
            hashofnonkeys[nk] = value_as_string
          end # if, inner
        elsif currentes.nonkeyattribtypes[i] == 'number'
          value_as_string.gsub!(/\s/, '') # get rid of blanks
        if value_as_string =~ /\./ or value_as_string =~ /[eE]-/
          hashofnonkeys[nk] = value_as_string.to_f
          puts 'String ' + value_as_string + ' converted to FLOAT with value ' + hashofnonkeys[nk].to_s
        else
          hashofnonkeys[nk] = value_as_string.to_i
          puts 'String ' + value_as_string + ' converted to INT with value ' + hashofnonkeys[nk].to_s
        end # if (different numerical types)
        else
          puts 'INVALID ATTRIBUTE TYPE: ' + nonkeyattribtypes[i]
          return nil
        end # if
      end # if value_as_string is not nil
    }
  end # if currentes.nonkeyattribnames

  # Instantiate new entity!
  newentity = Entity.new(esname, hashofkeys, hashofnonkeys)
  
  # install new entity!
  # First compute key.  Must go by the order defined in the entity set
  keyattribvaluearray = Array.new
  currentes.keyattribnames.each{|keyname|
    keyattribvaluearray << hashofkeys[keyname]
  }
  installationhashkey = keyattribvaluearray.join('#')
  puts '****About to install new entity with hash key = ' + installationhashkey
  currentes.hashofentities[installationhashkey] = newentity

end # def cen.rb
  
  
  

# Do ILE command ces
# ces : create entity set
# Syntax - 
# ces esname ||| keyattr_1 | type || ... || keyattr_n | type [||| nonkeyattr_1 | type || .... || nonkeyattr_m | type]
#          (blanks ignored)
#    where type (for now) = text or number
#    For non-key fields, real numbers are OK, and can be in scientific notation
#    In later versions, we should allow lots of other types, and even general objects 

# The argument passed to the function doesn't include the command keyword "ces"

def ces args, currentdb
  puts 'ces called with args string: ' + args
  if not currentdb
    puts 'no current database, do a cdb and a udb'
    return nil
  end # if no currentdb
  # defining type for regexps
  type = '(text|number)'

  
  args.strip!
  args_array = args.split(/\s*\|\|\|\s*/)

  esname = args_array[0]
  puts 'esname =  ' + esname
  keyattribstring = args_array[1].strip

  if not keyattribstring
    puts 'MUST have at least 1 key attribute!!'
    return nil
  end # if no key

  puts 'KEY attribute string = ' + keyattribstring

  keyattribarray = keyattribstring.split(/\s*\|\|\s*/)
  # arrays to store key attribute names and types
  keyattribnames = Array.new
  keyattribtypes = Array.new
  keyattribarray.each_with_index{|a,i|
    keyattribnames[i],keyattribtypes[i] = a.split(/\s*\|\s*/)
    if not keyattribtypes[i] =~ /^(text|number)$/
      puts 'All attributes must be of type "text" or "number"!'
      return nil
    end # if
  }
  if args_array[2] # if there are nonkeys
    nonkeyattribstring = args_array[2].strip
    nonkeyattribarray = nonkeyattribstring.split(/\s*\|\|\s*/)
    nonkeyattribnames = Array.new
    nonkeyattribtypes = Array.new
    nonkeyattribarray.each_with_index{|a,i|
      nonkeyattribnames[i],nonkeyattribtypes[i] = a.split(/\s*\|\s*/)
      if not nonkeyattribtypes[i] =~ /^(text|number)$/
        puts 'All attributes must be of type "text" or "number"!'
        return nil
      end # if
    }
  end 

  # Finally make the entity set and attach it to the database
  newes = EntitySet.new(esname, keyattribnames, keyattribtypes,
                        nonkeyattribnames, nonkeyattribtypes)
  # attach the entity set to the database
  currentdb.hes[esname] = newes

  puts '****** NEW ENTITY SET CREATED with the following info:'
  puts 'esname = ' + newes.esname
  puts 'key attrib names = ' + newes.keyattribnames.join(' ')
  puts 'key attrib type = ' + newes.keyattribtypes.join(' ')
  if newes.nonkeyattribnames
    puts 'non-key attrib names = ' + newes.nonkeyattribnames.join(' ')
    puts 'non-key attrib types = ' + newes.nonkeyattribtypes.join(' ')
  end # if
end # def ces 

# crs.rb - implementing the creation of a relationship set

# syntax: crs relsetname ||| esname_0 [(attrname|type ;... ; attrname|type)] ||
#                                                                     ...|| 
#                            esname_n-1 [(attrname|type ;... ; attrname|type)]
#         [||| relattrname_0 | type_0 || ... || relattrname_n-1 | type_n-1] 
# Square brackets mean optional.  Don't input the square brackets themselves in any case!

# Note: because of this, the symbols (); are reserved.  This could be corrected in later versions.
# Storing entity attributes and their types:

def crs args, currentdb
  puts 'crs called with args string: ' + args
  
  if not currentdb
    puts 'no current database, do a cdb and a udb'
    return nil
  end # if no currentdb

  args.strip!
  relsetname, es_string, attr_string = args.split(/\s*\|\|\|\s*/)

  if not relsetname
    puts 'ERROR: no relset name!!'
    return nil
  elsif not es_string
    puts 'ERROR: no entity set specs!!'
    return nil
  else
    puts 'relset name = ' + relsetname
    puts 'entity set specification string = ' + es_string
    if attr_string
      puts 'attribute spec string = ' + attr_string
    end # if attr_string
  end # if

  # Get the entity set names and make sure each entity exists
  es_string_array = es_string.split(/\s*\|\|\s*/)
  es_array = Array.new # this is an array whose elements are
  # Structs. The first element of this Struct is an entity set name,
  # whereas the second and third elements of the Struct are Arrays
  # of attribute names and attribute types, respectively.  These
  # are attributes of the entity pertaining to when they join the
  # relationship (not the entity's "static" attributes, or
  # the relationship's attributes).

  # So we define that struct here

  es_string_array.each{|es|
    puts '**processing this es name and possibly attrib string: ' + es
    md = es.match(/^\s*(.+)\s*(\(.+\))?/)
    if not md
      puts 'something may be wrong with the input or the code!!!'
      return nil
    end # if not md
    esname = md[1]
    puts 'esname = ' + md[1]
    if md[2]
      puts 'There is a list of attributes, namely: ' + md[2]
      # PROCESS ATTRIBUTE LIST
      md[2] =~ /\((.+)\)/
      attrlist = $1
      attrlist.strip!
      puts '****** Stripped attribute list = ' + attrlist
      
      attr_name_type_array = attrlist.split(/\s*;\s*/)
      attrname_array = Array.new
      attrtype_array = Array.new
      attr_name_type_array.each{|ant| # for each attribute name and attribute type
        # First separate name and type
        attrname, attrtype = ant.split(/\s*\|\s*/)
        attrname_array << attrname # putting a new attribute name into attrname_array
        attrtype_array << attrtype # putting a new attribute type into attrtype_array
      }

      es_array << Struct::ESStruct.new(esname, attrname_array, attrtype_array)

    else # no attributes
      puts 'No attributes for the entities for their involvement in relationships in this relset'
      es_array << Struct::ESStruct.new(esname, nil, nil)
    end # if md[2]
     
    if not currentdb.hes[esname]
      puts 'ERROR: Cannot create RELSET - nonexistent esname specified in crs instruction: ' + esname
      return nil # cannot create relset!!!
    else
      puts 'Checked entity set to be OK: ' + esname
    end # if nonexistent esname

  } # es_array.each

  # Now deal with the RELATIONSHIP attributes, if any

  attrname_array = Array.new
  attrtype_array = Array.new
  if attr_string
    attr_array = attr_string.split(/\s*\|\|\s*/)
    attr_array.each_with_index{|attrelement, i|
      attrname_array[i], attrtype_array[i] = attrelement.split(/\s*\|\s*/)
      if not attrtype_array[i].match(/(text|number)/)
        puts 'ERROR: incorrect type ' + attrtype_array[i]
        return nil
      end # if incorrect type
      puts 'attribute successfully processed: ' + attrname_array[i] + ' ' + attrtype_array[i]
    }
  end # if attr_string

  # make a new relset
  puts '****Just before calling Relset.new, es_array = ' + es_array.to_s
  newrelset = Relset.new(relsetname, es_array, attrname_array, attrtype_array, currentdb)
  # install new relset
  currentdb.hrs[relsetname] = newrelset

end # def crs


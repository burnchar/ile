# fe_uncond - find every, unconditional
# Takes entity set name as argument and dump all entities

def fe_uncond esname, currentdb
  currentes = currentdb.hes[esname]
  keyattribnames = currentes.keyattribnames
  nonkeyattribnames = currentes.nonkeyattribnames
  
  currentes.hashofentities.each_pair{|key, value|
    puts 'Entity key: ' + key
    # puts 'Entity: ' + value.inspect
  }


end # def

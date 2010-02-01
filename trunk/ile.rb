#!/usr/bin/ruby
require 'dbset'
require 'database'
require 'ces'
require 'entityset'
require 'entity'
require 'cen'
require 'fe_uncond'
require 'relset'
require 'relationship'
require 'cre'
require 'crs'
require 'tools'

# main loop for the ILE interpreter in Ruby
# Feb 2009

# First make a hash where we keep all the databases
# That is, we'll now just have 1 database set

dbset = DatabaseSet.new
# needed structs
Struct.new("ESStruct", :esname, :attribname_array, :attribtype_array)	
Struct.new("EAStruct", :entity, :attribhash)

# currentdb points to currently used database
currentdb = nil

while 1
  print 'ile >> '
 # resp = gets
  resp = Tools.getcommand

if not resp
    puts 'END OF INPUT'
    exit
  end
  puts 'Just read ' + resp
  if resp =~ /^#/ or resp =~ /^\s*$/
    puts 'Blank or comment line read'
    next
  end # if blank or comment line read
  resp.chomp!
  puts 'command read = ' + resp
  if resp =~ /^\s*#/ or resp =~ /^\s*$/
    puts 'Comment or blank line read.'
    next

  elsif resp =~ /^\s*exit\s*$/
    puts 'exiting'
    exit

  # cdb : create database command
  # In the future we can have database sets as well
  elsif resp =~ /^\s*cdb\s+(\w+)\s*$/
    dbname = $1
    newdb = Database.new(dbname)
    dbset.alldbs[dbname] = newdb
    puts 'Database created, called ' + dbname
  # udb : use databse
  elsif resp =~ /^\s*udb\s+(\w+)\s*$/
    dbname  = $1
    currentdb = dbset.alldbs[dbname]
    puts 'Using database called ' + dbname

  elsif resp =~ /^\s*cudb\s+(\w+)\s*$/
    dbname = $1
    newdb = Database.new(dbname)
    dbset.alldbs[dbname] = newdb
    puts 'Database created, called ' + dbname
    currentdb = newdb
    puts 'Using database called ' + dbname

  # ces : create entity set
  # Syntax - ces name key-attr_1 : type, ...., key-attr_n : type [; non-key-attr_1
  #     : type, ...., non-key-attr_m : type]
  #    where type (for now) = text or number
  #    Later on, allow lots of other types, and even general objects 

  elsif resp =~ /^\s*ces\s+(.+)\s*$/
    ces $1, currentdb
    
  # cen : create entity
  elsif resp =~ /^\s*cen\s+(.+)\s*$/
    puts 'cen to be called'
    cen $1, currentdb


  # crs : create relationship set
  elsif resp =~ /^\s*crs\s+(.+)\s*$/
    crs $1, currentdb

  # cre : create relationship
  elsif resp =~ /^\s*cre\s+(.+)\s*$/
    puts 'cre to be called'
    cre $1, currentdb

  # fe : find every entity in an entity set (there'll be versions with conditions too)
  elsif resp =~ /^\s*fe\s+(\w+)\s*$/
    # puts 'fe to be called, with only an entity set name given as argument'
    fe_uncond $1, currentdb

	
  end # if, main if statement
end # while, main loop




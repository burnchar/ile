# class database set
require 'database'
require 'entityset'
require 'entity'
require 'relset'
require 'relationship'
require 'utilities.rb'

class DatabaseSet
  def initialize(dsname, dsnote)
    @dsname = dsname.clone
    @dsnote = dsnote.clone
    @allDatabases = Hash.new # hash of REFERENCES to all the set's databases
  end

  # Saving a database set using Marshal
  # Too bad YAML seemingly doesn't work right now (Nov 2009)
  def saveDbset filename
    File.open(filename, 'w+') do |f|  
      Marshal.dump(self, f)  
    end 
    puts "Database set #{dsname} successfully saved to file called #{filename}"
  end

  def print_db_names
    # print all the names of the databases in this set
    puts 'Listing of all the databases of the dbset: ' + dsname
    @allDatabases.each_pair{|key,value|
      print 'Database key = "' + key + '",'
      puts '  Database name from Database object = "' + value.dbname + '"'
    }
  end # def print_db_names
  attr_reader :allDatabases, :dsname, :dsnote
  attr_writer :allDatabases, :dsname, :dsnote
end




# database.rb: defines an ILE database
class Database
  def initialize(dbname, dbnotes, ds)
    @dbname = dbname.clone
    @ds = ds
    @ds.allDatabases[@dbname] = self
    @dbnotes = dbnotes.clone
    @hes = Hash.new   # Hash of all entity set, hashed by their names.
    @hrs = Hash.new   # Hash of all relationship sets, also hashed by their names.
  end # def initialize

# recursive display of database
  def show
    puts '* database name, @dbname = ' + @dbname
    puts '* which belongs to database set name, @dsname = ' + @ds.dsname
    puts '* Now calling all entity sets to display themselves.....'
    if @hes
      @hes.each_value{|x| x.show}
    else
      puts 'No entity set to show'
    end # if
    
    if @hrs.size > 0
      puts '***** Now calling all relationship sets to display themselves.....'
      @hrs.each_value{|y| y.show}
    else
      puts 'RELATIONSHIP SETS? No relationship set exists in this database.'
    end # if
  end # show



  attr_accessor :dbname, :dsname, :hes, :hrs, :dbnotes
end # class Database
    

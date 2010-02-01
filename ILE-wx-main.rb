#!/usr/bin/env ruby
# I took a lot of 'boiler plate' code from the samples that came with wx2

begin
  require 'rubygems' 
rescue LoadError
end

require 'wx'
require 'database'
require 'entityset'
require 'entitysetdialogs'
require 'entitydialog'

class ILEMainFrame < Wx::Frame
  def initialize(parent, id = -1, title = "ILE Main Frame", 
                  pos   = Wx::DEFAULT_POSITION,
                  size  = Wx::DEFAULT_SIZE,
                  style = Wx::DEFAULT_FRAME_STYLE | Wx::RESIZE_BORDER | Wx::VSCROLL | Wx::HSCROLL)

    super(parent, id, title, pos, size, style)
  
    @allDS = Array.new # an array of all database set names
    # This is very un-ILE!  Next version we should make database set objects
    # with the name as an instance variable!



    # Define directory where the database sets are kept
    if ! Dir.exists? ILE_DATA_BASEDIR
      Dir.mkdir ILE_DATA_BASEDIR, 0755
    end

    # top-level sizer
    topLevelSizer = Wx::BoxSizer.new(Wx::VERTICAL)
 
    # Top row text box: current database set name
    # Second row text box: current database name
 
    # Deal with current database set.
    @currentDS = nil  # name of current database set
    @currentDSdir = nil # reference to current database set directory
    @currentDB = nil # current database

    gridBagSizer = Wx::GridBagSizer.new(10, 10)

    dsStaticText = Wx::StaticText.new(self, :label => "Current Database Set: ")
    @DSText = Wx::TextCtrl.new(self, :value => "", :size => [150, 20])
    @DSButton = Wx::Button.new(self, :label => 'Use DB Set')

    gridBagSizer.add(@DSText, Wx::GBPosition.new(0,1))
    gridBagSizer.add(@DSButton, Wx::GBPosition.new(0,2))

    # Now deal with current database.

    @currentDB = nil # reference to current database
    @currentDBfile = nil # reference to current database file object
    
    dbStaticText = Wx::StaticText.new(self, :label => "Current Database: ")
    @DBText = Wx::TextCtrl.new(self, :value => "", :size => [150, 20])
    @DBButton = Wx::Button.new(self, :label => "Use specified database")
    evt_button(Wx::ID_ANY){puts "SOME BUTTON was pressed!!"}
    
    gridBagSizer.add(dbStaticText, Wx::GBPosition.new(1,0))
    gridBagSizer.add(@DBText, Wx::GBPosition.new(1,1))
    gridBagSizer.add(@DBButton, Wx::GBPosition.new(1,2))

    topLevelSizer.add(gridBagSizer)

    sb21 = Wx::StaticBox.new(self, :label => "All Existing Database Sets")
    sb22 = Wx::StaticBox.new(self, :label => "All Databases in Current Database Set")
    sbs21 = Wx::StaticBoxSizer.new sb21, Wx::HORIZONTAL # doesn't matter which direction
    sbs22 = Wx::StaticBoxSizer.new sb22, Wx::HORIZONTAL
    gridBagSizer.add(sbs21, Wx::GBPosition.new(2,0), Wx::GBSpan.new(1,2))
    gridBagSizer.add(sbs22, Wx::GBPosition.new(2,2), Wx::GBSpan.new(1,2))

    # Make multi-line text controls and add them to sbs21 and sbs22
    @allds_text = Wx::TextCtrl.new(self, :style => Wx::TE_MULTILINE, :size => [350,200], :value => "")
    @alldb_text = Wx::TextCtrl.new(self, :style => Wx::TE_MULTILINE, :size => [350,200], :value => "")

    sbs21.add @allds_text
    sbs22.add @alldb_text

    # Set @allDS to reflect all the existing subdirectories of ILE_DATA_BASEDIR, except . and .. 
    Dir.foreach( ILE_DATA_BASEDIR ){|x|
      if x != '.' and x != '..'
        @allDS.push x
        @allds_text.append_text(x + "\n")
      end # if
    }

    # Now put some buttons for action specifications
    @editDatabaseSetButton = Wx::Button.new(self, :label => "Edit/Remove DB Set")
    gridBagSizer.add(@editDatabaseSetButton, Wx::GBPosition.new(3,0))
    @showDatabaseButton = Wx::Button.new(self, :label => "Show Current DB")
    gridBagSizer.add(@showDatabaseButton, Wx::GBPosition.new(3,1))
    @saveDatabaseButton = Wx::Button.new(self, :label => "Save Database")
    gridBagSizer.add(@saveDatabaseButton, Wx::GBPosition.new(3,2))
    @editDatabaseButton = Wx::Button.new(self, :label => "Edit/Remove Database")
    gridBagSizer.add(@editDatabaseButton, Wx::GBPosition.new(3,3))

    @newEntitySetButton = Wx::Button.new(self, :label => "New Entity Set")
    gridBagSizer.add(@newEntitySetButton, Wx::GBPosition.new(4,0))

    # need text controls for the number of key an


    @editEntitySetButton = Wx::Button.new(self, :label => "Edit/Remove Entity Set")
    gridBagSizer.add(@editEntitySetButton, Wx::GBPosition.new(4,2))

    @newEntityButton = Wx::Button.new(self, :label => "New Entity")
    gridBagSizer.add(@newEntityButton, Wx::GBPosition.new(5,0))
    @editEntityButton = Wx::Button.new(self, :label => "Edit/Remove Entities")
    gridBagSizer.add(@editEntityButton, Wx::GBPosition.new(5,2))

    # operations on relationship sets
    @newRelsetButton = Wx::Button.new(self, :label => "New Relset")
    gridBagSizer.add(@newRelsetButton, Wx::GBPosition.new(6,0))
    @editRelsetButton = Wx::Button.new(self, :label => "Edit/Remove Relset")
    gridBagSizer.add(@editRelsetButton, Wx::GBPosition.new(6,2))

    # operations on relationships
    @newRelationshipButton = Wx::Button.new(self, :label => "New Relationship")
    gridBagSizer.add(@newRelationshipButton, Wx::GBPosition.new(7,0))
    @editRelationshipButton = Wx::Button.new(self, :label => "Edit/Remove Relationship")
    gridBagSizer.add(@editRelationshipButton, Wx::GBPosition.new(7,2))

    # query operations
    @queryButton = Wx::Button.new(self, :label => "Query Operations")
    gridBagSizer.add(@queryButton, Wx::GBPosition.new(8,0))


    set_sizer(topLevelSizer)
    create_status_bar()
    set_status_text(Wx::VERSION_STRING)
    fit
    # react when user presses button to create or use new database set
    evt_button(@DSButton) do
      @currentDS = @DSText.get_line_text(0)
      @currentDS.chomp!
      puts '@currentDS = ' + @currentDS
      if (@currentDS =~ /^[[:alnum:]_]+$/) 
        @currentDSdir = ILE_DATA_BASEDIR + '/' + @currentDS
        
        if ! Dir.exists? @currentDSdir
          
          Dir.mkdir @currentDSdir, 0755
          puts 'Made new directory ' + @currentDSdir + ' successfully.'
          @allDS.push @currentDS
          
        end
        @allds_text.set_value ''
        @allDS.each {|x|
          @allds_text.append_text (x + "\n")
        }
        # if valid directory name
      else
        puts "Directory name must consist only of letters, digits, and underscore"
      end
    end # evt_button(@DSButton) do
    
    # react to database button
    evt_button(@DBButton) do
      currentDB = @DBText.get_line_text(0)
      puts "Attempting to create or use DB named " + currentDB
      # First make sure we're using a database set
      if (! @currentDS)
        puts "Error: Must be using some database set to create or use a database!" 
      else
        # if the database by that name doesn't exist (no file), then create a new Database object
        if !File.exists?(@currentDSdir + '/' + currentDB + '.ile')
          puts "Database doesn't yet exist, must create it."
          @currentDB = Database.new(currentDB, @currentDS)
          puts "Created and using a new Database named " + @currentDB.dbname
          # Now create an empty file representing the database
          @currentDBfile = File.new(@currentDSdir + '/' + currentDB + '.ile', File::CREAT|File::EXCL, 0644)
        else # file exists, just open it for read only
# PROBLEM: Currently the plan is to completely scrap the old file and remake the database file each time
# the db is saved!!  If we use YAML successfully, there must be way to just update the old file!!
# New note: actually probably there's no easy way to just update old file, since YAML and Marshal are both serialization schemes,
# which by definition doesn't allow incremental updates, I think.
          @currentDBfile = File.new(@currentDSdir + '/' + currentDB + '.ile', 'r')
          puts 'Database exists, opened file for read only'
          @currentDB = Database.new(currentDB, @currentDS)
        end # if, inner

        # Ask for a note about this database; right now just a one-liner since there's a ready-made dialog
        # for that.

# PROBLEM: if db already exists, it exists as a file.  But we also need a @currentDB object to exist!


        dialog = Wx::TextEntryDialog.new(self, :caption => 'Note describing this database',
                                              :defaultValue => @currentDB.dbnotes)
        dialog.show_modal
        @currentDB.dbnotes = dialog.get_value
      end # if, outer
      
    end #evt_button(@DBButton)
     
    # react to user pressing show db button
    evt_button(@showDatabaseButton) do
      if @currentDB
        @currentDB.show
      else
        puts 'NO CURRENT DATABASE!!'
      end # if
    end # evt_button(@showDBButton)


   
    # Now if the user presses the make-an-entity-set button!!
    # Use a custom dialog!!
    evt_button(@newEntitySetButton) do

      dialog1 = EntitySetDialog1.new(self, "New Entity Set Dialog 1")
      # Have a loop to make sure all the fields are filled in a valid way

      # MUST FIX THIS... When user press CANCEL in the dialog box, we must let them cancel
      # making a new entity set, that is, go back to the main page.

      ok = false
      while ! ok
        case dialog1.show_modal         
        when Wx::ID_CANCEL
          puts 'User hit CANCEL!!'
         
        when Wx::ID_OK
          if dialog1.numkeys.to_i > 0
            ok = true
          end # if
        end # case
      end # while
      esn = dialog1.esname
      desc = dialog1.description
      k = dialog1.numkeys.to_i
      nk = dialog1.numnonkeys.to_i
     
      # NOW MUST MAKE A DIALOG TO LET USER INPUT NAMES AND TYPES OF THE ATTRIBUTES OF THE ENTITY SET!!
  
# Have arrays ready to contain key and nonkey attribute names
# Also have hashes ready for their types
      keyNameArray = Array.new
      keyTypeHash = Hash.new
      nonkeyNameArray = Array.new
      nonkeyTypeHash = Hash.new

      dialog2 = EntitySetDialog2.new(self, "New Entity Set Dialog 2", k, nk)
      ok = false
      while !ok
        puts 'Just about to call dialog2.show_modal'
        case dialog2.show_modal
        when Wx::ID_CANCEL
          puts 'User hit cancel, returnin!!'
       
        when Wx::ID_OK
          0.upto(k-1){|i|
            keyNameArray[i] = dialog2.keyNameArray[i]
            keyTypeHash[keyNameArray[i]] = dialog2.keyTypeArray[i]
          }

          0.upto(nk-1){|j|
            nonkeyNameArray[j] = dialog2.nonkeyNameArray[j]
            nonkeyTypeHash[nonkeyNameArray[j]] = dialog2.nonkeyTypeArray[j]
          }

# Check input
          allnames = (keyNameArray.clone.concat nonkeyNameArray)
          if allnames == allnames.uniq
            ok = true
            # Make sure the types have all been chosen
            k.times{|i|
              if keyTypeHash[keyNameArray[i]] == 0
                puts 'ERROR: type not chosen for key name = ' + keyNameArray[i]
                ok = false
                break
              end # if
            } # k.times
            if !ok 
              break
            end # if
            nk.times{|j|
              if nonkeyTypeHash[nonkeyNameArray[j]] == 0
                puts 'ERROR: type not chosen for non-key name = ' + nonkeyNameArray[j]
                ok = false
                break
              end # if
            } # nk.times
          end # if

          puts 'BACK FROM DIALOG 2'
# need default case
        end # case dialog2.show_modal
        puts '*****ENDING WHILE LOOP WITH ok = ' + ok.to_s
      end # while

      puts 'successfully gotten entity set key and nonkey names and types'
      puts 'keys: '
      keyNameArray.each{|keyname|
        puts keyname + ' ' + keyTypeHash[keyname].inspect
      }


# CONVERT key type hash members from numerical values to descriptive symbols
# current...  :text, :number, :range, :date
      keyTypeHash.each_pair{|hashkey, v|
        case v
        when 1
          keyTypeHash[hashkey] = :text
        when 2
          keyTypeHash[hashkey] = :number
        when 3
          keyTypeHash[hashkey] = :range
        when 4
          keyTypeHash[hashkey] = :date
        else
          puts 'ERROR: key type = ' + v.to_s + ' not supported!!'
         
        end # case
      }


# CONVERT non-key type hash members from numerical values to descriptive symbols
      # currently.... :text, :number, :range, :date

      nonkeyTypeHash.each_pair{|hashkey, v|
        case v
        when 1
          nonkeyTypeHash[hashkey] = :text
        when 2
          nonkeyTypeHash[hashkey] = :number
        when 3
          nonkeyTypeHash[hashkey] = :range
        when 4
          nonkeyTypeHash[hashkey] = :date
        else
          puts 'ERROR: non-key type = ' + v.to_s + ' not supported!!'
         
        end # case
      }


      puts 'nonkeys: '
      nonkeyNameArray.each{|nkname|
        puts nkname + ' ' + nonkeyTypeHash[nkname].inspect
      } 

# HERE IS CODE FOR MAKING NEW ENTITY SET

      newes = EntitySet.new(esn, desc, keyNameArray, keyTypeHash, 
                            nonkeyNameArray, nonkeyTypeHash, @currentDB)
      puts 'Create a new entity set called : ' + esn
      puts '   with this description : ' + desc
      puts 'The current database name is : ' + @currentDB.dbname
      puts 'The current database set name is : ' + @currentDB.dsname
    end # do evt_button(@newEntitySetButton)

# process button for new entity
    evt_button(@newEntityButton) do
      # puts 'must complete code here, popping up a dialog box'

      edn = EntityDialog.new(self, "New Entity Dialog", @currentDB)

      case edn.show_modal
      when Wx::ID_CANCEL
        puts 'User hit CANCEL!!' 
      
      when Wx::ID_OK
        puts 'USER HITS OK, MUST CONTINUE CODING HERE!!!!!!!!!!'


      else 
        puts "SOMETHING'S WRONG HERE, dialog box returns invalid value"
       
      end # case
    end # evt_button(@newEntityButton)

  end # initialize, in ILEMainFrame class



end # class ILEMainFrame



class ILEApp < Wx::App
  def on_init
    frame = ILEMainFrame.new(nil, -1, "ILE Main Frame",
                         Wx::Point.new(10, 100),
                         Wx::Size.new(800,600))

    set_top_window(frame)
    frame.show()
  end
end

ILE_DATA_BASEDIR = "ile_data_basedir"
ILEApp.new.main_loop()

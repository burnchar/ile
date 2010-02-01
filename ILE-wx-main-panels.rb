#!/usr/bin/env ruby
# I took a lot of 'boiler plate' code from the samples that came with wx2

begin
  require 'rubygems' 
rescue LoadError
end

require 'wx'
require 'database'

class ILEMainFrame < Wx::Frame
  def initialize(parent, id = -1, title = "ILE Main Frame", 
                  pos   = Wx::DEFAULT_POSITION,
                  size  = Wx::DEFAULT_SIZE,
                  style = Wx::DEFAULT_FRAME_STYLE)

    super(parent, id, title, pos, size, style)
  
    @allDS = Array.new # an array of all database set names
    # This is very un-ILE!  Next version we should make database set objects
    # with the name as an instance variable!



    # Define directory where the database sets are kept
    if ! Dir.exists? ILE_DATA_BASEDIR
      Dir.mkdir ILE_DATA_BASEDIR, 0755
    end


    # evt_size { puts "I was resized!" }

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
          return
        when Wx::ID_OK
          if dialog1.numkeys.to_i > 0
            ok = true
          end # if
        end # case
      end # while
      esn = dialog1.esname.to_s
      desc = dialog1.description.to_s
      k = dialog1.numkeys.to_i
      nk = dialog1.numnonkeys.to_i
     
      # NOW MUST MAKE A DIALOG TO LET USER INPUT NAMES AND TYPES OF THE ATTRIBUTES OF THE ENTITY SET!!
      retvalKeyHash = Hash.new
      retvalNonkeyHash = Hash.new
      dialog2 = EntitySetDialog2.new(self, "New Entity Set Dialog 2", k, nk)
      ok = false
      while ! ok
        puts 'Just about to call dialog2.show_modal'
        case dialog2.show_modal
        when Wx::ID_CANCEL
          return
        when Wx::ID_OK


          puts 'BACK FROM DIALOG 2, NEED TO COMPLETE THIS CODE>>>>'
# need default case
        end # case
        ok = true
      end # while

    end # do evt_button(@newEntitySetButton)


  end # initialize, in ILEMainFrame class


end # class ILEMainFrame

# Two custom dialogs are used when user asks to make an entity set
# The first one asks for a description of the entity set, and the numbers of key, nonkey attributes
# The second one then asks for the name and type of each attribute.
# first custom dialog when user asks to make an entity set
# Modified from http://rubyforscientificresearch.blogspot.com/2009/05/dialogs-in-wxruby.html


# CANCEL doesn't work!  Can't cancel this dialog yet

class EntitySetDialog1 < Wx::Dialog
  attr_reader :esname, :description, :numkeys, :numnonkeys
  def initialize(parent, title)
    super(parent, Wx::ID_ANY, title, :style => Wx::DEFAULT_DIALOG_STYLE | Wx::RESIZE_BORDER)
    esname_textctrl = Wx::TextCtrl.new(self)
    evt_text(esname_textctrl){|e|
      @esname = esname_textctrl.value
    }

    description_textctrl = Wx::TextCtrl.new(self, :style => Wx::TE_MULTILINE)
    evt_text(description_textctrl){|e|
      @description = description_textctrl.value
    }
    numkeys_textctrl = Wx::TextCtrl.new(self)
    evt_text(numkeys_textctrl){|e|
      @numkeys = numkeys_textctrl.value.to_i
    }
    numnonkeys_textctrl = Wx::TextCtrl.new(self)
    evt_text(numnonkeys_textctrl){|e|
      @numnonkeys = numnonkeys_textctrl.value.to_i
    }
    
    items_sizer = Wx::FlexGridSizer.new(2,4, 10, 10) # rows, cols, hgap, vgap
    items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, 'E. S. Name'))
    items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, 'E. S. Description'))
    items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, 'No. Key Attributes'))
    items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, 'No. Non-Key Attributes'))
    items_sizer.add(esname_textctrl, 2)
    items_sizer.add(description_textctrl, 2, Wx::GROW)
    items_sizer.add(numkeys_textctrl, 2)  
    items_sizer.add(numnonkeys_textctrl, 2)

    
    main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    main_sizer.add(items_sizer, 0, Wx::ALL | Wx::GROW, 10)
    main_sizer.add(create_separated_button_sizer(Wx::OK | Wx::CANCEL),
                   0, Wx::ALL | Wx::GROW, 5)
    
    set_sizer main_sizer
    fit
  end # initialize

end # class EntitySetDialog1

# Second entity set dialog, asking for attribute names and types
# Put a scrolled window inside for 

class EntitySetDialog2 < Wx::Dialog

# FOR NOW JUST PUT THE KEY STUFF IN A PANEL.  SAME FOR NONKEY STUFF.  FORGET SCROLLING!!!

  attr_reader :keyNameArray, :keyTypeArray, :nonkeyNameArray, :nonkeyTypeArray
  def initialize(parent, title, k, nk)
  
    super(parent, -1, title, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE)

    top_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    set_sizer top_sizer

    rvh  = Hash.new  # return value hash
    top_sizer.add OurPanel.new(self, k)


    # Here make use of key type choices.....


    # NOW MUST DEAL WITH THE NON KEYS

    #button_sizer = Wx::StdDialogButtonSizer.new
    #button_sizer.add_button( Wx::Button.new(self, Wx::ID_OK, "OK") )
    #button_sizer.add_button( Wx::Button.new(self, Wx::ID_CANCEL, "Cancel") )
    #button_sizer.realize
    
   # top_sizer.add(button_sizer)
 
  
    
    

  end # initialize
    


end # class EntitySetDialog2

# panel for either key or nonkey type
class OurPanel < Wx::Panel
  attr_reader :attribNameArray, :attribTypeArray
  # Parameters for initializer:
  # Input parameters:
  # parent: obviously parent of this panel
  # numAttribs: number of (key or nonkey as appropriate) attributes
  # returns a hash consisting of 2 arrays, one of attribute names and 
  # the other one of attribute type
  def initialize(parent, numAttribs)
  
    super(parent)
    @attribNameArray = Array.new # array of attribute names to be input by user
    @attribTypeArray = Array.new # array of attribute types to be input by user
    
    nameTextCtrl = Array.new # array of text controls
    typeChoices = Array.new  # array of choice boxes of attribute types

    set_background_colour(Wx::WHITE)
     
    items_sizer = Wx::FlexGridSizer.new(numAttribs,4,10, 10) 
    set_sizer items_sizer

     
    numAttribs.times do |i|
      puts 'processing i = ' + i.to_s
      # attribute name
      nameTextCtrl[i] = Wx::TextCtrl.new(self)
      items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, 'Name of Attribute ' + i.to_s))
      items_sizer.add(nameTextCtrl[i])
      evt_text(nameTextCtrl[i]){|e|
        @attribNameArray[i] = nameTextCtrl[i].value
      }
      # attribute type - eventually allow user-defined types
      choices = ['text', 'number', 'range', 'date']
      typeChoices[i] = Wx::Choice.new(self, :choices => choices)
      items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, 'Type of Attribute ' + i.to_s))
      items_sizer.add(typeChoices[i])
      evt_choice(typeChoices[i]){|e|
        puts 'Choice event happened'
        @attribTypeArray[i] = typeChoices[i].value
      }
    end # nameArray.size.times
  end # initialize
end # class keyScrolledWindow


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

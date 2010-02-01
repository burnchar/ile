#!/usr/bin/ruby
# ILE main widget, an attempt
# May 2009
# Vitit Kantabutra
# Department of Computer Science
# Idaho State University

require 'Qt'
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
class MainWidget < Qt::Widget
  def initialize(dbset_in, parent=nil)
    super(parent)
    @dbset = dbset_in
    # set the size policy of the main widget to Minimum
    # setSizePolicy(Qt::SizePolicy::Fixed, Qt::SizePolicy::Fixed)
   
    make_main_menu


  end # initialize main widget

  def dispose_buttons
    @newdb_button.dispose
    @exit_button.dispose
    @newes_button.dispose
    @newen_button.dispose
    @newrs_button.dispose
    @newre_button.dispose
  end # dispose_buttons
  
  def dispose_innards
    # dispose of all the children of self, the main widget
    children.each{|c|
      puts 'Disposing child: ' + c.to_s
      c.dispose
    } if children

  end # dispose_innards
  
  def make_main_menu
    #    resize(0,0) # Doesn't help!!
    #    show

    dispose_innards
  
    # install buttons and labels
    @action_label = Qt::Label.new(self)
    # size size policy of the label to Minimum
    # @action_label.setSizePolicy(Qt::SizePolicy::Fixed, Qt::SizePolicy::Fixed)
    @newdb_button = Qt::PushButton.new(self)
    @usedb_button = Qt::PushButton.new(self)
    @newes_button = Qt::PushButton.new(self)
    @newen_button = Qt::PushButton.new(self)
    @newrs_button = Qt::PushButton.new(self)
    @newre_button = Qt::PushButton.new(self)
    @exit_button = Qt::PushButton.new(self)

    @outer_layout = Qt::VBoxLayout.new(self)
 
    @inner_layout = Qt::GridLayout.new(2,10) # OK to have more cols than needed

    @outer_layout.addLayout(@inner_layout)
    @outer_layout.addWidget(@action_label)
    @inner_layout.addWidget(@newdb_button,0,0)
    @inner_layout.addWidget(@usedb_button,1,0)
    @inner_layout.addWidget(@newes_button,0,1)
    @inner_layout.addWidget(@newen_button,1,1)
    @inner_layout.addWidget(@newrs_button,0,2)
    @inner_layout.addWidget(@newre_button,1,2)
    @inner_layout.addWidget(@exit_button,0,3)
 
    @newdb_button.show
    @usedb_button.show
    @newes_button.show
    @newen_button.show
    @newrs_button.show
    @newre_button.show
    @action_label.show   
    @exit_button.show

    @action_label.setText("Welcome to ILE!")
    @newdb_button.setText("NEW DB")
    @usedb_button.setText("USE DB")
    @newes_button.setText("NEW ENTITY SET")
    @newen_button.setText("NEW ENTITY")
    @newrs_button.setText("NEW RELSET")
    @newre_button.setText("NEW RELATIONSHIP")
    @exit_button.setText("EXIT")

    # resize main widget to default size
    puts 'sizeHint of @action_label = ' + @action_label.sizeHint.inspect
    @action_label.resize(@action_label.sizeHint)
    puts 'sizeHint of main widget = ' + self.sizeHint.inspect
    resize(sizeHint)
    #  @outer_layout.setMargin(0)
    #   @outer_layout.setSpacing(0)

    # Connecting signal and slot
    connect(@newdb_button, SIGNAL('clicked()' ),
            self, SLOT('newdb_button_clicked()' ))
    connect(@usedb_button, SIGNAL('clicked()' ),
            self, SLOT('usedb_button_clicked()' ))
    connect(@exit_button, SIGNAL('clicked()' ),
            self, SLOT('exit_button_clicked()' ))
    connect(@newes_button, SIGNAL('clicked()' ),
            self, SLOT('newes_button_clicked()' ))
    connect(@newen_button, SIGNAL('clicked()' ),
            self, SLOT('newen_button_clicked()' ))
    connect(@newrs_button, SIGNAL('clicked()' ),
            self, SLOT('newrs_button_clicked()' ))
    connect(@newre_button, SIGNAL('clicked()' ),
            self, SLOT('newre_button_clicked()' ))

    
  end # make_main_menu


  def newdb_button_clicked
    @action_label.setText("NEW DB button was clicked")
    dispose_buttons # must do this to make buttons not show!!
    @outer_layout.removeItem(@inner_layout) # get rid of old buttons
    @inner_layout.dispose

    # Insert new widgets for entering new db name
    @dbname_textedit = Qt::TextEdit.new(self)
    @outer_layout.addWidget(@dbname_textedit)
    @dbname_textedit.setText("Replace this text with new DB name")
    @dbname_textedit.show
    @newdb_submitnamebutton = Qt::PushButton.new('SUBMIT',self)
    @outer_layout.addWidget(@newdb_submitnamebutton)
    connect(@newdb_submitnamebutton, SIGNAL('clicked()'),
            self, SLOT('newdb_submitnamebutton_clicked()'))
    @newdb_submitnamebutton.show
  end # newdb_button_clicked

  def exit_button_clicked
    exit
  end # exit_button_clicked

  def newes_button_clicked
    # Make a GUI for entering a new entity set
    dispose_innards
    
    # Make up widgets for inputting esname and number of key and nonkey fields
    # Then the next screen will ask for field names and types
    @layout = Qt::GridLayout.new(self,3,3)
    @layout.setSpacing 10
    # labels
    @esname_label = Qt::Label.new(self)
    @esname_label.setText('ESNAME')
    @layout.addWidget(@esname_label,0,0)
    @esname_label.show
    @k_label = Qt::Label.new(self)
    @k_label.setText 'NUMBER OF KEYS'
    @layout.addWidget(@k_label,0,1)
    @k_label.show
    @nk_label = Qt::Label.new(self)
    @nk_label.setText 'NUMBER OF NON-KEYS'
    @layout.addWidget(@nk_label,0,2)
    @nk_label.show

    @esname = Qt::TextEdit.new(self)
    @numkeys = Qt::TextEdit.new(self)
    @numnonkeys = Qt::TextEdit.new(self)
    @submit = Qt::PushButton.new('SUBMIT',self)
    @cancel = Qt::PushButton.new('CANCEL',self)
    @layout.addWidget(@esname,1,0)
    @layout.addWidget(@numkeys,1,1)
    @layout.addWidget(@numnonkeys,1,2)
    @esname.show
    @numkeys.show
    @numnonkeys.show
    @layout.addWidget @submit, 2, 0
    @submit.show
    @layout.addWidget @cancel, 2, 1
    @cancel.show

    # Now must CONNECT the button click signal to handler!!
    # The handler will present a window for entering details about
    # the fields
    connect(@submit, SIGNAL('clicked()' ),
            self, SLOT('newes_submitted1()' ))
    connect(@cancel, SIGNAL('clicked()' ),
            self, SLOT('make_main_menu()' ))

  end # newes_button_clicked

  def usedb_button_clicked
    dispose_innards
    # must remake the outer layout because we threw it away!
    # maybe better to keep it, but for now let's go with this scheme!
    @outer_layout = Qt::VBoxLayout.new(self)

    # Insert new widgets for entering db name
    @dbname_textedit = Qt::TextEdit.new(self)
    @outer_layout.addWidget(@dbname_textedit)
    @dbname_textedit.setText("Replace this text with DB name")
    @dbname_textedit.show
    @db_submitnamebutton = Qt::PushButton.new('SUBMIT',self)
    @outer_layout.addWidget(@db_submitnamebutton)
    connect(@db_submitnamebutton, SIGNAL('clicked()'),
            self, SLOT('db_submitnamebutton_clicked()'))
    @db_submitnamebutton.show
    
  end  

  def newen_button_clicked
    @action_label.setText("NEW ENTITY button was clicked")
    dispose_buttons # must do this to make buttons not show!!
    @outer_layout.removeItem(@inner_layout) # get rid of old buttons
    @inner_layout.dispose
  end # newen_button_clicked

  def newrs_button_clicked
    @action_label.setText("NEW RELSET button was clicked")
    dispose_buttons # must do this to make buttons not show!!
    @outer_layout.removeItem(@inner_layout) # get rid of old buttons
    @inner_layout.dispose
  end # newes_button_clicked

  def newre_button_clicked
    @action_label.setText("NEW RELATIONSHIP button was clicked")
    dispose_buttons # must do this to make buttons not show!!
    @outer_layout.removeItem(@inner_layout) # get rid of old buttons
    @inner_layout.dispose
  end # newen_button_clicked

  # slots for processing ILE commands
  def newdb_submitnamebutton_clicked

#  TO DO:
#     make sure the name of the db is new

    dbname = @dbname_textedit.text
    dbname.gsub!("\n",'')

    puts 'Submitted new db name is ' + dbname

    # if db name is not new, go back
    # We'll use the assumption that the db hash storage keys are the same
    # as the db names.  This assumption is valid for now at least!

    if (@dbset.alldbs.has_key?(dbname))
      puts 'In the if'
      dispose_innards 
      @layout = Qt::VBoxLayout.new(self)
      @label = Qt::Label.new(self)
      @layout.addWidget(@label)
      
      labelText = "DATABASE EXISTS!!\n\nValid database names are:\n"
      @dbset.alldbs.each_value{|v| # could've used each_index but afraid
        # that in the future the indices may not be strings, whereas the
        # @dbname field in the database object itself will always a string.
        labelText = labelText + v.dbname + "\n"
      }
      @label.setText(labelText)
      @label.show

      # Need a text area for new db name
      @dbname_textedit = Qt::TextEdit.new(self)
      @dbname_textedit.setText("Replace this with a new db name")
      @layout.addWidget(@dbname_textedit)
      @dbname_textedit.show
      
      # Now a button for returning to window for submitting db name
      @goback = Qt::PushButton.new(self)
      @layout.addWidget(@goback)
      @goback.setText('Re-Enter Database Name')
      # Do a connection.  The effect of pressing the goback button is the
      # same as pressing the newdb_button
      connect(@goback, SIGNAL('clicked()'),
              self, SLOT('newdb_submitnamebutton_clicked()'))
      @goback.show
      
     
    else
      
      # Destroy all the innards and remake them
      dispose_innards
      @outer_layout = Qt::VBoxLayout.new(self)
      @dbname_textedit = Qt::TextEdit.new(self)
      @outer_layout.addWidget(@dbname_textedit)
      @dbname_textedit.show

      # The following runs if the dbname is new
      puts 'dbname supplied is OK'
      @newdb = Database.new(dbname)
      @dbset.alldbs[dbname] = @newdb # I think this will work, since
      # ruby passes the ref to the database set, even though the passing
      # is done by value.
      
      # Now show the set of all databases, name and object id
      # Just use the same TextEdit box
      # Change the text on the submit box to dismiss
      display = "ALL DATABASES IN DATABASE SET:\n\n"
      @dbset.alldbs.each_pair{|i,x|
        display = display + i.to_s + "\t'"
        display = display + x.to_s + "\n"
      }
      @dbname_textedit.setText display
      
      # Destroy the button and make a new one.
      # Maybe I should code something that makes up the original menu
      # so we can reuse it!
      #disconnect(@newdb_submitnamebutton, SIGNAL('clicked()'),
      #           self, SLOT('newdb_submitnamebutton_clicked()')) # Necessary?
      @newdb_submitnamebutton.dispose
      @tomain_button = Qt::PushButton.new(self)
      connect(@tomain_button, SIGNAL('clicked()'),
              self, SLOT('make_main_menu()'))
      @tomain_button.setText('TO MAIN MENU')



# PROBLEM: already destroyed all the innards! So @outerlayout no longer exists
 
      @outer_layout.addWidget(@tomain_button)
      @tomain_button.show
    end
  end # newdb_submitnamebutton_clicked

  # The slot below is used for the "USE DB" command
  def db_submitnamebutton_clicked
    dbname = @dbname_textedit.text
    
    # got to make sure the database name supplied is valid!!!
    # If not, say something and go back to asking for a dbname again
    if !(@dbset.alldbs[dbname])
      dispose_innards
      @layout = Qt::VBoxLayout.new(self)
      @label = Qt::Label.new(self)
      @layout.addWidget(@label)
      labelText = "INVALID DATABASE NAME\n\nValid database names are:\n"
      @dbset.alldbs.each_value{|v| # could've used each_index but afraid
        # that in the future the indices may not be strings, whereas the
        # @dbname field in the database object itself will always a string.
        labelText = labelText + v.dbname + "\n"
      }
      # Now a button for returning to window for submitting db name
      @goback = Qt::PushButton.new(self)
      @layout.addWidget(@goback)
      @goback.setText('Re-Enter Database Name')
      # Do a connection.  The effect of pressing the goback button is the
      # same as pressing the newdb_button
      connect(@goback, SIGNAL('clicked()'),
              self, SLOT('usedb_button_clicked()'))

      return
    end # if supplied db name is not valid
    @currentdb = @dbset.alldbs[dbname] 
    
    # Destroy the button and make a new one.

    disconnect(@db_submitnamebutton, SIGNAL('clicked()'),
               self, SLOT('db_submitnamebutton_clicked()')) # Necessary?
    @db_submitnamebutton.dispose
    @tomain_button = Qt::PushButton.new(self)
    connect(@tomain_button, SIGNAL('clicked()'),
            self, SLOT('make_main_menu()'))
    @tomain_button.setText('TO MAIN MENU')
    @outer_layout.addWidget(@tomain_button)
    @tomain_button.show
    
  end # db_submitnamebutton_clicked

  def newes_submitted1
    

  end # newes_submitted1

  slots 'newdb_button_clicked()', 'exit_button_clicked()',
  'usedb_button_clicked()',
  'newes_button_clicked()', 'newen_button_clicked()',
  'newrs_button_clicked()', 'newre_button_clicked()',
  'newdb_submitnamebutton_clicked()', 'make_main_menu()',
  'db_submitnamebutton_clicked()', 'newes_submitted1()'
  
  

  
end

# Make a database set, the only one for this version
dbset = DatabaseSet.new

# structures needed
Struct.new("ESStruct", :esname, :attribname_array, :attribtype_array)	
Struct.new("EAStruct", :entity, :attribhash)

# Make a new Qt application object
a = Qt::Application.new(ARGV)
mw = MainWidget.new(dbset)
a.setMainWidget(mw)
mw.show
a.exec

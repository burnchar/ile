# entitysetdialogs.rb

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
  
    super(parent, -1, title, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, 
          :style=>Wx::DEFAULT_DIALOG_STYLE | Wx::RESIZE_BORDER | Wx::VSCROLL | Wx::HSCROLL )

    @keyNameArray = Array.new
    @keyTypeArray = Array.new
    @nonkeyNameArray = Array.new
    @nonkeyTypeArray = Array.new
    top_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    set_sizer top_sizer
   
    keyNameTextCtrls = Array.new # array of text controls
    keyTypeChoices = Array.new  # array of choice boxes of attribute types
    nonkeyNameTextCtrls = Array.new
    nonkeyTypeChoices = Array.new

    items_sizer = Wx::FlexGridSizer.new(k + nk, 4, 10, 10) 
 
# code for dealing with KEYS
    k.times do |i|
      puts 'Keys: processing i = ' + i.to_s
      # key name
      keyNameTextCtrls[i] = Wx::TextCtrl.new(self)
      items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, 'KEY NAME ' + i.to_s))
      items_sizer.add(keyNameTextCtrls[i])
      evt_text(keyNameTextCtrls[i]){|e|
        (@keyNameArray)[i] = keyNameTextCtrls[i].value
      }
      # key type - eventually allow user-defined types
      choices = ['CHOOSE', 'text', 'number', 'range', 'date']
      keyTypeChoices[i] = Wx::Choice.new(self, :choices => choices)
      items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, 'KEY TYPE ' + i.to_s))
      items_sizer.add(keyTypeChoices[i])
      evt_choice(keyTypeChoices[i]){|e|
        puts 'Choice event happened'
        (@keyTypeArray)[i] = keyTypeChoices[i].get_selection
      }
    end # times
 
# NOW DEAL WITH NONKEYS
     nk.times do |i|
      puts 'non-keys: processing i = ' + i.to_s
      # nonkey name
      nonkeyNameTextCtrls[i] = Wx::TextCtrl.new(self)
      items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, 'NON-KEY NAME ' + i.to_s))
      items_sizer.add(nonkeyNameTextCtrls[i])
      evt_text(nonkeyNameTextCtrls[i]){|e|
        (@nonkeyNameArray)[i] = nonkeyNameTextCtrls[i].value
      }
      # nonkey type - eventually allow user-defined types
      choices = ['CHOOSE', 'text', 'number', 'range', 'date']
      nonkeyTypeChoices[i] = Wx::Choice.new(self, :choices => choices)
      items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, 'NON-KEY TYPE ' + i.to_s))
      items_sizer.add(nonkeyTypeChoices[i])
      evt_choice(nonkeyTypeChoices[i]){|e|
        puts 'Choice event happened'
        (@nonkeyTypeArray)[i] = nonkeyTypeChoices[i].get_selection
      }
    end # times

    top_sizer.add(items_sizer, 0, Wx::ALL | Wx::GROW, 10)
    top_sizer.add(create_separated_button_sizer(Wx::OK | Wx::CANCEL),
                   0, Wx::ALL | Wx::GROW, 5)

    fit
  end # initialize
end # class EntitySetDialog2

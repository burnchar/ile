# entitydialog.rb, defining dialog boxes for entities


# Note, Saturday Oct 10, 2009: This file has messed up logic and must be fixed.

class EntityDialog < Wx::Dialog
  @@currentES = nil # reset by user by means of a choice widget
  attr_reader :keyArray, :nonkeyArray
  def initialize(parent, title, currentDB)
    if !currentDB
      puts "Must be using some current database!!"
      return
    end # if no current db
    super(parent, Wx::ID_ANY, title, :style => Wx::DEFAULT_DIALOG_STYLE | 
          Wx::RESIZE_BORDER)
    # Places for holding key and non-key values typed in by the user

# Must derive, from currentDB and selected Entity Set, the following: keyNameArray, keyTypeHash,
#                nonkeyNameArray, nonkeyTypeHash)

# I don't want the user to have to say what the current Entity Set is every time he/she
# enters a new entity.  So the program reads all the entity set names from the database
# and make an array out of that.

    keyNameArray = nil
    nonkeyNameArray = nil

    esnames = Array.new # array of all entity set names in current db
    esnames.push 'CHOOSE ENTITY SET'
    currentDB.hes.each_value{|es|
      puts 'Pushing entity set name = ' + es.esname
      esnames = esnames.push es.esname
    }
    main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)

    es_choice = Wx::Choice.new(self, :choices => esnames)
    main_sizer.add(es_choice)

    es_choice_button = Wx::Button.new(self, :label => 'GO')
    main_sizer.add es_choice_button
    items_sizer = Wx::GridBagSizer.new(10, 10)

    # set choice to the same as last time *if there's a last time*, unless user makes a new choice
    if @@currentES
      (es_choice.set_selection @@currentES)
# set keyNameArray and nonkeyNameArray.....
      # 'MUST SET KEY AND NONKEY NAME ARRAYS IN THE CODE!!!'
      chosen_es_name = esnames[@@currentES]
      chosen_es = currentDB.hes[chosen_es_name]
      keyNameArray = chosen_es.keyattribnames
      nonkeyNameArray = chosen_es.nonkeyattribnames
      keyTypeHash = chosen_es.keyattribtypes
      nonkeyTypeHash = chosen_es.nonkeyattribtypes
      keyValueTextCtrls = Array.new
      nonkeyValueTextCtrls = Array.new

      keyNameArray.size.times do |i|
        puts 'Keys: processing i = ' + i.to_s
        
        items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY,
              'ENTER KEY NAMED ' + keyNameArray[i]), Wx::GBPosition.new(i,0))
        items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY,
              ' OF TYPE ' + keyTypeHash[keyNameArray[i]].to_s), Wx::GBPosition.new(i,1))
        
        case keyTypeHash[keyNameArray[i]] 
        when :text
          keyValueTextCtrls[i] = Wx::TextCtrl.new(self, :style => Wx::TE_MULTILINE)
          items_sizer.add(keyValueTextCtrls[i], Wx::GBPosition.new(i, 2))    
       
          # Now figure out and code what to do in case text changes in one of these text controls
          evt_text(keyValueTextCtrls[i]) do 
            @keyArray[i] = keyValueTextCtrls[i].value
          end # do evt_text
          
        when :number
          keyValueTextCtrls[i] = Wx::TextCtrl.new(self)
          items_sizer.add(keyValueTextCtrls[i], Wx::GBPosition.new(i, 2))  
      
          # Now figure out and code what to do in case text changes in one of these text controls
          evt_text(keyValueTextCtrls[i]) do 
            if keyValueTextCtrls[i].value =~/\./
              @keyArray[i] = keyValueTextCtrls[i].value.to_f
            else
              @keyArray[i] = keyValueTextCtrls[i].value.to_i
            end # evt_text
            puts 'Just put in a datum of class ' + @keyArray[i].class
          end # do evt_text
          
        when :range
          # to be coded
          puts 'TO BE SUPPORTED IN THE FUTURE'
          
        when :date
          # to be coded
          puts 'TO BE SUPPORTED IN THE FUTURE'
        end # case
      end # do
      
# NON-KEYS are to be dealt with now.
      nonkeyNameArray.size.times do |i|
        puts 'Non-Keys: processing i = ' + i.to_s
        
        items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY,
              'ENTER NON-KEY NAMED ' + nonkeyNameArray[i]), Wx::GBPosition.new(i,0))
        items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY,
              ' OF TYPE ' + nonkeyTypeHash[nonkeyNameArray[i]].to_s), Wx::GBPosition.new(i,1))
        
        case nonkeyTypeHash[nonkeyNameArray[i]] 
        when :text
          nonkeyValueTextCtrls[i] = Wx::TextCtrl.new(self, :style => Wx::TE_MULTILINE)
          items_sizer.add(nonkeyValueTextCtrls[i], Wx::GBPosition.new(i, 2))    
       
          # Now figure out and code what to do in case text changes in one of these text controls
          evt_text(nonkeyValueTextCtrls[i]) do 
            @nonkeyArray[i] = nonkeyValueTextCtrls[i].value
          end # do evt_text
          
        when :number
          nonkeyValueTextCtrls[i] = Wx::TextCtrl.new(self)
          items_sizer.add(nonkeyValueTextCtrls[i], Wx::GBPosition.new(i, 2))  
      
          # Now figure out and code what to do in case text changes in one of these text controls
          evt_text(nonkeyValueTextCtrls[i]) do 
            if nonkeyValueTextCtrls[i].value =~/\./
              @nonkeyArray[i] = nonkeyValueTextCtrls[i].value.to_f
            else
              @nonkeyArray[i] = nonkeyValueTextCtrls[i].value.to_i
            end # evt_text
            puts 'Just put in a datum of class ' + @nonkeyArray[i].class
          end # do evt_text
          
        when :range
          # to be coded
          puts 'TO BE SUPPORTED IN THE FUTURE'
          
        when :date
          # to be coded
          puts 'TO BE SUPPORTED IN THE FUTURE'
        end # case
      end # do (nonkey)
      
    end # if
    
    evt_button(es_choice_button) do
      @@currentES = es_choice.get_selection # this will be a number!!!
      puts 'The selection is ' + @@currentES.to_s + ' corresp to esname = ' +
        esnames[@@currentES]
# Have to figure out entity set name from this index, which starts at 1!!!
      if es_choice.get_selection > 1
        chosen_es_name = esnames[@@currentES]
        chosen_es = currentDB.hes[chosen_es_name]
        keyNameArray = chosen_es.keyattribnames
        nonkeyNameArray = chosen_es.nonkeyattribnames
        keyTypeHash = chosen_es.keyattribtypes
        nonkeyTypeHash = chosen_es.nonkeyattribtypes
        keyValueTextCtrls = Array.new
        nonkeyValueTextCtrls = Array.new
        
        keyNameArray.size.times do |i|
          puts 'Keys: processing i = ' + i.to_s
          
          items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY,
                                             'ENTER KEY NAMED ' + keyNameArray[i]), Wx::GBPosition.new(i,0))
          items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY,
                                             ' OF TYPE ' + keyTypeHash[keyNameArray[i]].to_s), Wx::GBPosition.new(i,1))
          
          case keyTypeHash[keyNameArray[i]] 
          when :text
            keyValueTextCtrls[i] = Wx::TextCtrl.new(self, :style => Wx::TE_MULTILINE)
            items_sizer.add(keyValueTextCtrls[i], Wx::GBPosition.new(i, 2))    
            
            # Now figure out and code what to do in case text changes in one of these text controls
            evt_text(keyValueTextCtrls[i]) do 
              @keyArray[i] = keyValueTextCtrls[i].value
            end # do evt_text
            
          when :number
            keyValueTextCtrls[i] = Wx::TextCtrl.new(self)
            items_sizer.add(keyValueTextCtrls[i], Wx::GBPosition.new(i, 2))  
            
            # Now figure out and code what to do in case text changes in one of these text controls
            evt_text(keyValueTextCtrls[i]) do 
              if keyValueTextCtrls[i].value =~/\./
                @keyArray[i] = keyValueTextCtrls[i].value.to_f
              else
                @keyArray[i] = keyValueTextCtrls[i].value.to_i
              end # evt_text
              puts 'Just put in a datum of class ' + @keyArray[i].class
            end # do evt_text
            
          when :range
            # to be coded
            puts 'TO BE SUPPORTED IN THE FUTURE'
            
          when :date
            # to be coded
            puts 'TO BE SUPPORTED IN THE FUTURE'
          end # case
        end # do
        
        nonkeyNameArray.size.times do |i|
          puts 'Non-Keys: processing i = ' + i.to_s
          
          items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY,
                                             'ENTER NON-KEY NAMED ' + nonkeyNameArray[i]), Wx::GBPosition.new(i,0))
          items_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY,
                                             ' OF TYPE ' + nonkeyTypeHash[nonkeyNameArray[i]].to_s), Wx::GBPosition.new(i,1))
          
          case nonkeyTypeHash[nonkeyNameArray[i]] 
          when :text
            nonkeyValueTextCtrls[i] = Wx::TextCtrl.new(self, :style => Wx::TE_MULTILINE)
            items_sizer.add(nonkeyValueTextCtrls[i], Wx::GBPosition.new(i, 2))    
            
            # Now figure out and code what to do in case text changes in one of these text controls
            evt_text(nonkeyValueTextCtrls[i]) do 
              @nonkeyArray[i] = nonkeyValueTextCtrls[i].value
            end # do evt_text
            
          when :number
            nonkeyValueTextCtrls[i] = Wx::TextCtrl.new(self)
            items_sizer.add(nonkeyValueTextCtrls[i], Wx::GBPosition.new(i, 2))  
            
            # Now figure out and code what to do in case text changes in one of these text controls
            evt_text(nonkeyValueTextCtrls[i]) do 
              if nonkeyValueTextCtrls[i].value =~/\./
                @nonkeyArray[i] = nonkeyValueTextCtrls[i].value.to_f
              else
                @nonkeyArray[i] = nonkeyValueTextCtrls[i].value.to_i
              end # evt_text
              puts 'Just put in a datum of class ' + @nonkeyArray[i].class
            end # do evt_text
            
          when :range
            # to be coded
            puts 'TO BE SUPPORTED IN THE FUTURE'
            
          when :date
            # to be coded
            puts 'TO BE SUPPORTED IN THE FUTURE'
          end # case
        end # do (nonkey)
        puts 'Just about to fit!!'
        fit
      end # if
    end # evt_choice      

    @keyArray = Array.new
    @nonkeyArray = Array.new

    # for each key, have a text box for entering key and non-key values
    keyValueTextCtrls = Array.new
    nonkeyValueTextCtrls = Array.new

    main_sizer.add(items_sizer, 0, Wx::ALL | Wx::GROW, 10)
    main_sizer.add(create_separated_button_sizer(Wx::OK | Wx::CANCEL),
                   0, Wx::ALL | Wx::GROW, 5)
      
    set_sizer main_sizer
    fit
  end # initialize


end # class EntityDialog

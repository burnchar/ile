# getcommand reads lines and buffer them up so long as the last nonblank, non-eol char is not '|'
class Tools
  def Tools.getcommand
    done = false
    akku = ''
    while not done
      lineread = gets
      lineread.chomp!
      lineread.strip!

      if lineread[lineread.length-1, lineread.length-1] != '|'
        done = true
      end # if done
      if akku == ''
        akku = lineread
      else
        akku = akku + ' ' + lineread
      end # if akku
    end # while
    return akku
  end # Tools.getcommand
end # class Tools

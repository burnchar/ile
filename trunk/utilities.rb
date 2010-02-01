class Range

  def overlap?(range)
    self.include?(range.first) || range.include?(self.first)
  end



end
# Source: Daniel Schierbeck, from http://opensoul.org/2007/2/13/ranges-include-or-overlap-with-ranges 

# The following code is by Vitit Kantabutra
# Extending the Array class to test for subsets and supersets,
# a slow but simple quadratic-complexity program
# Source: http://www.informit.com/articles/article.aspx?p=26943
class Array
  def subset?(other)
    self.each do |x|
      if !(other.include? x)
        return false
      end
    end
    true
  end
  
  def superset?(other)
    other.subset?(self)
  end
end

# Beautifying the Hash class' to_s method
class Hash
  def to_s
    retval = '{'
    self.each_pair{|k, v|
      retval = retval + k.to_s + '=>' + v.to_s + ', '
    }
    retval.chop!
    retval.chop!
    retval = retval + '}'
  end # to_s
end # class Hash

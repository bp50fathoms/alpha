module Visitable
  def accept(visitor, *args)
    visitor.send("visit_#{self.class.name.gsub(/(.+::)+/, '').downcase}",
                 self, *args)
  end
end

struct Kakoune::Position
  property line
  property column

  def initialize(@line = 0, @column = 0)
  end
end

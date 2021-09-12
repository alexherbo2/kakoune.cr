struct Kakoune::Position
  property line : Int32
  property column : Int32

  def initialize(@line = 0, @column = 0)
  end
end

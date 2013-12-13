class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def pink
    colorize(35)
  end

  # metodo para generar unha cadea aleatoria
  # metemolo dentro dos metodos de clase de String
  # pa chamalo usamos String.random(i)
  class << self
    def random(i=8)
      o =  [('a'..'z'),('0'...'9')].map{|i| i.to_a}.flatten
      (0...i).map{ o[rand(o.length)] }.join
    end
  end              
end
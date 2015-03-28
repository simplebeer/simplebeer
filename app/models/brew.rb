class Brew
  attr_accessor :name, :slug

  def initialize(params = {})
    @name = params[:name]
    @slug = params[:name].parameterize
  end
end

# A nice model for a blog!
class Article
  include Mongoid::Document
  include Mongoid::Urls
  field :title
  url :title
end

# A model with dynamic key
class Company
  include Mongoid::Document
  include Mongoid::Urls
  field :name
  field :nick

  url :nick, :name, :fullname

  def fullname
    return nick + ' - ' + name if nick && name
    nick || name
  end
end

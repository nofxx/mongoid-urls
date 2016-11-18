# A model with dynamic key
class Company
  include Mongoid::Document
  include Mongoid::Urls
  field :name
  field :nick

  has_many :articles
  url :nick, :name, :fullname

  def fullname
    return nick + ' - ' + name if nick && name
    nick || name
  end
end

# A nice model for a blog!
class Article
  include Mongoid::Document
  include Mongoid::Urls
  field :title
  belongs_to :company, optional: true
  url :title
end

class Article
  include Mongoid::Document
  include Mongoid::Urls
  field :title
  url :title
end
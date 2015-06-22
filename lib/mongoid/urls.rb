require 'mongoid'
require 'babosa'

module Mongoid
  # Creates friendly urls for mongoid models!
  module Urls
    extend ActiveSupport::Concern
    included do
      cattr_accessor :reserved_words,
                     :url_simple,
                     :url_scope,
                     :url_key
    end

    # Methods avaiable at the model
    module ClassMethods
      #
      # The #url
      #
      #  url :title
      #
      #  :simple    ->   Only one url per instance
      #  :reserve   ->   Defaults to %w( new edit )
      #
      def url(*args)
        options = args.extract_options!
        fail 'One #url per model!' if url_key
        self.url_key = args.first.to_s
        self.url_simple = options[:simple]
        self.reserved_words = options[:reserve] || Set.new(%w(new edit))
        create_url_fields
        before_validation :create_urls
      end

      def find_by_url(u)
        url_simple ? find_by(url: u) : find_by(urls: u)
      rescue Mongoid::Errors::DocumentNotFound
        nil
      end

      private

      def create_url_fields
        if url_simple
          field :url, type: String
          index({ url: 1 }, unique: true)
        else
          field :urls, type: Array, default: []
          index(urls: 1)
        end
      end
    end # ClassMethods

    def to_param
      url_simple ? url : urls.last
    end

    def slug
      self[url_key].to_slug.normalize.to_s
    end

    protected

    def validate_urls(u)
      if self.class.find_by_url(u)
        errors.add(:title, :uniqueness)
      elsif reserved_words.include?(u)
        errors.add(:title, :reserved)
      else
        true
      end
    end

    def create_urls
      return unless changes.include?(url_key)
      validate_urls(new_url = slug)

      return self.url = new_url if url_simple
      urls << new_url
      urls.uniq!
    end
  end # Urls
end # Mongoid

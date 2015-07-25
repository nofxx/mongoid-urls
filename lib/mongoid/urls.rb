require 'mongoid'
require 'babosa'

module Mongoid
  # Creates friendly urls for mongoid models!
  module Urls
    extend ActiveSupport::Concern
    included do
      cattr_accessor :reserved_words,
                     :url_simple,
                     # :url_scope,
                     :url_keys
    end

    # Methods avaiable at the model
    module ClassMethods
      #
      # The #url
      #
      #  url :title
      #
      #  :simple    ->   Only one url per instance
      #  :reserve   ->   Defaults to %w( new edit ) + I18n.locales
      #
      def url(*args)
        options = args.extract_options!
        fail 'One #url per model!' if url_keys
        self.url_keys = args # .first.to_s
        self.url_simple = options[:simple]
        create_url_fields
        create_url_validations(options)
      end

      def create_url_validations(options)
        before_validation :create_urls
        reserve = Set.new(%w(new edit)) + (options[:reserved] || [])
        reserve << I18n.available_locales if Object.const_defined?('I18n')
        self.reserved_words = reserve.flatten
        validates :url, uniqueness: true, presence: true,
                        format: { with: /[a-z\d-]+/ }
      end

      def find_url(u)
        find_by(url: u) || (!url_simple && find_by(urls: u))
      rescue Mongoid::Errors::DocumentNotFound
        nil
      end
      alias_method :find_by_url, :find_url

      private

      def create_url_fields
        field :url, type: String
        index({ url: 1 }, unique: true)
        define_method('url=') do |val|
          self[:url] = val.to_slug.normalize.to_s
        end
        return if url_simple
        field :urls, type: Array, default: []
        index(urls: 1)
      end
    end # ClassMethods

    def to_param
      url
    end

    def new_url
      url_keys.each do |key|
        val = send(key)
        next if val.blank?
        url = val.to_slug.normalize.to_s
        next if self.class.find_url(url)
        return url
      end
      nil
    end

    protected

    def validate_url(slug)
      return unless reserved_words.include?(slug)
      errors.add(:url, :reserved)
    end

    def create_urls
      return unless (slug = new_url)
      validate_url(slug)

      self.url = slug
      return if url_simple
      urls << slug
      urls.uniq!
    end
  end # Urls
end # Mongoid

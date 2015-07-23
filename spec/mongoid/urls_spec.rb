require 'spec_helper'

describe Mongoid::Urls do
  let(:document_class) do
    Object.send(:remove_const, :Document) if Object.const_defined?(:Document)
    # A sample model
    class Document
      include Mongoid::Document
      include Mongoid::Urls
      field :title
      field :doc
    end
    Class.new(Document)
  end

  let(:document) do
    document_class.create(title: "I'm a Document!")
  end

  let(:article) do
    Article.new(title: "I'm an Article!")
  end

  describe '#url' do
    before(:each) { document_class.send(:url, :title) }
    it 'should slugize a few stuff' do
      expect(document.url).to eq('im-a-document')
    end

    it 'should update url' do
      document.title = 'I "quoted"'
      document.valid?
      expect(document.url).to eq('i-quoted')
    end

    it 'should keep old urls' do
      article.save
      article.title = 'Hello Ruby!'
      article.save
      expect(article.urls).to eq ['im-an-article', 'hello-ruby']
    end
  end

  describe '#url' do
    describe 'default ":title"' do
      before(:each) { document_class.send(:url, :title) }

      it 'should be created' do
        expect(document).to have_field(:urls)
      end

      it 'should be valid' do
        expect(document).to be_valid
      end

      it 'should be persisted' do
        document.save
        # why the anonymous #document_class doesn't work?
        expect(Document.count).to eq(1)
      end

      it 'should create secondary index' do
        expect(document.index_specifications).to_not be_empty
      end
    end

    describe 'options' do
      it 'should accept custom field names' do
        document_class.send(:url, :title)
        expect(document).to have_field(:url)
      end

      it 'should accept simple field names' do
        document_class.send(:url, :title, simple: true)
        expect(document).to_not have_field(:urls)
        expect(document).to have_field(:url)
      end
    end

    describe 'index field' do
      it 'should accept custom field names' do
        document_class.send(:url, :doc)
        expect(document).to have_field(:url)
      end

      it 'should accept simple field names' do
        document_class.send(:url, :doc, simple: true)
        expect(document).to_not have_field(:urls)
        expect(document).to have_field(:url)
      end

      it 'should create simple field to_param' do
        document_class.send(:field, :name)
        document_class.send(:url, :name, simple: true)
        doc = document_class.create(name: 'nice doc')
        expect(doc.to_param).to eq('nice-doc')
      end

      it 'should not create custom finders with default id' do
        # A sample model
        class UntaintedDocument
          include Mongoid::Document
          include Mongoid::Urls
          field :name
        end
        dc = Class.new(UntaintedDocument)

        dc.send(:url, :name)
        expect(dc.public_methods).to include(:find_by_url)
      end

      it 'should change `to_param`' do
        document_class.send(:url,  :title)
        expect(document.to_param).to eq document.urls.first
      end
    end
  end

  describe 'callbacks' do
    context 'when the article is a new record' do
      it 'should create the urls after being saved' do
        expect(article.urls).to be_empty
      end

      it 'should create the urls after being saved' do
        article.save
        expect(article.urls).to eq ['im-an-article']
      end
    end

    context 'when the article is not a new record' do
      it 'should not change the title after being saved' do
        title_before = article.title
        article.save
        expect(article.title).to eq title_before
      end

      it 'should create a new title after being saved' do
        article.title = 'Fresh new tomato'
        article.save
        expect(article.urls).to include 'fresh-new-tomato'
      end

      context 'when the article is initialized with a title' do
        it 'should not change the title after being saved' do
          title = 'test title'
          expect(Article.create!(title: title).title).to eq title
        end
      end
    end

    context 'when the article is cloned' do
      it 'should set the title to nil' do
        d2 = article.clone
        expect(d2.urls).to be_empty
      end
    end
  end

  describe 'finders' do
    it 'should create a custom find method' do
      document_class.send(:url, :title)
      expect(document.class.public_methods).to include(:find_by_url)
    end

    it 'should find something with the custom find method' do
      article.save
      from_db = Article.find_by_url(article.urls.first)
      expect(from_db.id).to eq(article.id)
    end
  end

  describe '.to_param' do
    it 'should respond with last valid url' do
      document_class.send(:url, :title)
      expect(document.to_param).to eq 'im-a-document'
    end
  end

  describe 'reserved words' do
    before(:each) do
    end
    it 'should respect default new' do
      article.title = 'new'
      expect(article.save).to be_falsey
      expect(article.errors).to include(:title)
    end

    it 'should respect default edit' do
      article.title = 'edit'
      expect(article.save).to be_falsey
      expect(article.errors).to include(:title)
    end

    it 'should match' do
      article.title = 'anew'
      expect(article.save).to be_truthy
    end

    it 'should match' do
      article.title = 'newa'
      expect(article.save).to be_truthy
    end
  end

  describe '(no) collision resolution' do
    before(:each) do
      document_class.send(:url, :title)
      document_class.create_indexes
    end

    context 'when creating a new record' do
      it 'should raise when collisions can\'t be resolved on save' do
        article.save
        d2 = article.clone
        expect(d2).to_not be_valid
        expect(d2.save).to be_falsey
        expect(d2.errors.messages).to include(:url)
      end

      it 'should raise when collisions can\'t be resolved on create!' do
        article.title = '1234'
        article.save
        dup = Article.create(title: '1234')
        expect(dup.errors.messages).to_not be_empty
      end
    end

    context 'with other url present' do
      before(:each) do
        document_class.send(:field, :name)
        document_class.send(:index, { name: 1 }, unique: true)
        document_class.create_indexes
      end

      context 'when violating the other index' do
        it 'should raise an operation failure' do
          expect { document_class.send(:url, :name) }
            .to raise_exception(RuntimeError)
        end
      end
    end
  end
end

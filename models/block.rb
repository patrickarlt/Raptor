class Block

  @queue = :block

  include Mongoid::Document
  include Mongoid::Slug

  field :title, type: String
  slug :title, history: true

end

class MarkdownBlock < Block

  field :content, type: String
  field :html_content, type: String
  
  before_save :convert_markdown

  def render(&block)
    block.call
  end

  private 

  # Internal: converts the :content field (markdown) to html and stores the result in :html_content
  #
  # Returns nothing
  def convert_markdown
    self.html_content = Raptor::Markdown.render(self.content)
  end

end

class TwitterBlock < Block

  include Mongoid::Document
  
  field :username, type: String
  
  embeds_many :tweets

  def render(limit, &block)
    block.call
  end

end

class Tweet
  include Mongoid::Document
  
  field :content, type: String
  field :html_content, type: String
  field :created_at, type: DateTime
  field :twitter_id, type: String

  embedded_in :twitterBlock

  before_save :parse_tweet

  private

  def parse_tweet

  end

end

class NavigationBlock < Block

end

class ImageBlock < Block
  
end

class ListBlock < Block
  
end
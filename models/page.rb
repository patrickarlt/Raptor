class Page

  @queue = :pages

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Tree
  include Mongoid::Search
  include Mongoid::Slug

  field :title, type: String
  field :content, type: String
  field :html_content, type: String
  field :status, type: String, default: "inactive"
  field :path , type: String
  
  slug :title, history: true

  search_in :title, :content

  before_save :convert_markdown
  before_save :rebuild_path
  after_rearrange :rebuild_path

  index :path
  
  default_scope where(status: "active")
  
  private

  # Internal: converts the :content field (markdown) to html and stores the result in :html_content
  #
  # Returns nothing
  def convert_markdown
    self.html_content = Raptor::Markdown.render(self.content)
  end
  
  # Internal: rebuilds the path this page can be accessed at
  #
  # Returns nothing
  def rebuild_path
    self.path = self.ancestors_and_self.collect(&:slug).join('/')
  end
  
end
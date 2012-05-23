class Post

  @queue = :posts

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  include Mongoid::Search
  include Mongoid::Slug

  field :title, type: String
  field :content, type: String
  field :html_content, type: String
  field :status, type: String, default: "idea"
  slug :title, history: true
  search_in :title, :content

  before_save :convert_markdown

  belongs_to :user

  index :slug

  default_scope order_by(:created_at, :desc)

  scope :published, where(status: "published")
  scope :ideas, where(status: "idea")
  scope :scheduled, where(status: "scheduled")
  scope :before, ->(date) {where(:created_at.lte => date)}
  scope :after, ->(date) {where(:created_at.gte => date)}
  scope :between, ->(startTime, endTime) {where(:created_on.gte => startTime, :created_on.lte => endTime)}

  # Public: Builds a criteria object from query params
  #
  # skip     - (Integer) Return posts from this page
  # limit    - (Integer) Alias for per_page
  # slug     - (String)  String representing the post slug
  # id       - (Integer) Integer representing the post id
  # before   - (Date)    Returns all posts before Date
  # after    - (Date)    Returns all posts after Date
  # from     - (Date)    Returns all posts from Date (also requires to)
  # to       - (Date)    Returns all posts to Date (also requires from)
  # status   - (String)  String representing publish status (published, idea, scheduled)
  # order    - (String)  ASC or DESC
  # order_by - (String)  Field to order on
  #
  # Returns a mongoid criteria object containing the requested posts
  def self.build_criteria query_request={}   
    query_mash = Hashie::Mash.new({
      'limit' => 10,
      'status' => "published"
    }.merge(query_request))
    criteria = Mongoid::Criteria.new(self)
    # Date Scopes
    criteria = criteria.where(:created_at.lte => query_mash.before) if query_mash.before?
    criteria = criteria.where(:created_at.gte => query_mash.after) if query_mash.after?
    criteria = criteria.where(:created_on.gte => query_mash.from, :created_on.lte => query_mash.to) if query_mash.from? && query_mash.to?
    # Status Scopes
    criteria = criteria.where(status: "idea") if query_mash.status === "idea"
    criteria = criteria.where(status: "scheduled") if query_mash.status === "scheduled"
    criteria = criteria.where(status: "published") if query_mash.status === "published"
    # Pagination Scopes
    criteria = criteria.skip(query_mash.skip.to_i) if query_mash.skip?
    if query_mash.limit.to_i == -1
      criteria = criteria.all_in
    else
      criteria = criteria.limit(query_mash.limit)
    end
    
    # Ordering
    criteria = criteria.order_by(query_mash.order_by, query_mash.order) if query_mash.order? && query_mash.order_by?
    criteria = criteria.order_by(query_mash.order_by, query_mash.order) if !query_mash.order? && query_mash.order_by?
    criteria = criteria.order_by.asc if query_mash.order === :asc
    criteria = criteria.order_by.desc if query_mash.order === :desc
    criteria
  end

  private

  # Internal: converts the :content field (markdown) to html and stores the result in :html_content
  #
  # Returns nothing
  def convert_markdown
    self.html_content = Raptor::Markdown.render(self.content)
  end
  
end
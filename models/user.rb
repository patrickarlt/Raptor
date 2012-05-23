class User

  @queue = :users

  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :email, type: String
  field :name, type: String
  field :password, type: String
  
  has_many :posts
  
  validates_presence_of :email, message:{status:422,type:"invalid_input", message:"email is required"}
  validates_presence_of :password, message:{status:422,type:"invalid_input", message:"password is required"}
  validates_uniqueness_of :email, message:{status:409,type:"conflict", message:"email is already taken"}
  validates_format_of :email, with: /.+\@.+\..+/, message: {status:422, type:"invalid_input", message:"email is invalid"}
  
  before_create :hash_password
  
  default_scope without(:password)

  def authenticates? password
    BCrypt::Password.new(self.read_attribute(:password)) == password
  end
  
  protected
  
  def hash_password password = nil
    password ||= self.password
    self.password =  BCrypt::Password.create(password)
  end

end
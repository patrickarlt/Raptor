class Token

  @queue = :token

  include Mongoid::Document
  include Mongoid::Timestamps::Created
  
  field :token, type: String
  field :type, type: String
  attr_protected :token
  
  before_create :set_token

  validates_format_of :type, with: /read|write/, message: {status:422, type:"invalid_input", message:"type must be 'read' or 'write'"}
  validates_uniqueness_of :type, message: {status:409, type:"conflict", message:"you can only have one read or write token"}

  protected
  
  def set_token
    self.token = self.type[0] + "-" + generate_token
  end

  def generate_token size = 32
    OpenSSL::Random.random_bytes(size/2).unpack('H*').first
  end

end
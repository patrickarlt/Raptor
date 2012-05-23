class ImageUploader < CarrierWave::Uploader::Base 
  include CarrierWave::MiniMagick 
 
  storage :file 
 
  def store_dir 
    "public/uploads/images" 
  end 
 
  def extensions_white_list 
    %w(jpg jpeg gif png) 
  end 
 
  #process :resize_to_limit => [720,720] 
  #version :icon40 do 
  #  process :resize_to_fill => [40,40] 
  #end 
  #version :icon60 do 
  #  process :resize_to_fill => [60,60] 
  #end 
  #version :profile do 
  #  process :resize_to_limit => [180,180] 
  #end 
end 

class Media

  @queue = :media

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  include Mongoid::Search
  include Mongoid::Slug

  field :title, type: String
  field :description, type: String
  slug :title, history: true

  search_in :title, :description

end

class Image < Media
  field :image
  mount_uploader :image, ImageUploader
end
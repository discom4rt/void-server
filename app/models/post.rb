class Post < ActiveRecord::Base
  has_many :users_posts
  has_many :users, :through => :users_posts
  has_many :users_random_posts, :dependent => :destroy
  has_many :random_users, :through => :users_random_posts, :source => :user
  has_many :likes
  has_many :likers, :through => :likes, :source => :user

  attr_accessible :image, :location, :message, :latitude, :longitude

  has_attached_file :image,
  :styles => {
    :square => '720x720^'
  },
  :convert_options => {
    :square => " -gravity center -extent 720x720",
  }

  validates :image, :presence => true
  validates :location, :presence => true

  # get a random post that this user has not already received
  def self.random(user)
    related_posts = user.related_posts
    scope = Post
    scope = scope.where('id NOT IN (?)', related_posts.map(&:id)) unless related_posts.empty?
    scope.first(:offset => rand(Post.count - related_posts.count))
  end

  def image_url
  	image.url(:square)
  end

  def liked_by_user?(user)
    likers.where(:id => user.id).exists?
  end

  def as_json(options = {})
    json = super(options)
    json['liked'] = liked_by_user?(options[:liker]) if options[:liker]
    json
  end

end

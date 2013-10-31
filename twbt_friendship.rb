# coding: utf-8

require 'twitter'
require 'yaml'

BASE_DIR = File.dirname($0)
CONFIG_YAML = BASE_DIR+"/config.yaml"
config = YAML.load_file(CONFIG_YAML)

# config
Twitter.configure do |c|
  c.consumer_key       = config["consumer_key"]
  c.consumer_secret    = config["consumer_secret"]
  c.oauth_token        = config["access_token"]
  c.oauth_token_secret = config["access_token_secret"]
end

# リフォローするメソッド
def refollow_all(followers, friends, pending_users)
  followed = Array.new
  followers.each do |follower|
    unless friends.include?(follower)
      unless pending_users.include?(follower)
        Twitter.follow(follower)
        followed << follower
      end
    end
  end

  followed
end

# 一方的にフォローしているユーザをリムーブするメソッド
def unfollow_all(followers, friends)
  unfollowed = Array.new
  friends.each do |friend|
    unless followers.include?(friend)
      Twitter.unfollow(friend)
      unfollowed << friend
    end
  end

  unfollowed
end

followers = Twitter.follower_ids.collection
friends = Twitter.friend_ids.collection
pending_users = Twitter.friendships_outgoing.collection

followed = refollow_all(followers, friends, pending_users)
puts Time.now.to_s+" followed"
p followed

unfollowed = unfollow_all(followers, friends)
puts Time.now.to_s+" unfollowed"
p unfollowed


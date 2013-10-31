# coding: utf-8

require 'twitter'
require 'yaml'

# 設定読み込み
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

# 発言パターン読み込み
random_pattern = YAML.load_file(BASE_DIR+"/"+config["random_pattern_yaml"])

pattern = random_pattern.sample
puts Time.now.to_s+" "+pattern
Twitter.update(pattern)


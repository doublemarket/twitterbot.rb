# coding: utf-8

require 'twitter'
require 'yaml'
require 'pp'

# define consts
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

# 返信パターンと前回チェックした最後のツイートを取得
reply_pattern = YAML.load_file(BASE_DIR+"/"+config["reply_pattern_yaml"])
last_tweet = YAML.load_file(BASE_DIR+"/"+config["last_tweet_yaml"])

# タイムライン取得
if last_tweet.nil? or !last_tweet
  timeline = Twitter.home_timeline(:exclude_replies => true, :include_rts => false)
else
  timeline = Twitter.home_timeline(:exclude_replies => true, :include_rts => false, :since_id => last_tweet.id)
end

puts Time.now.to_s+" "+timeline.size.to_s

timeline.each do |t|
  # 自分自身へのリプライはしない
  next if t.from_user == config["screen_name"]

  position = {}
  # reply_patternに一致する文字列の位置をposision["パターン"]に入れる
  reply_pattern.each do |p|
    position[p[0]] = /#{p[0]}/ =~ t.text if matched = /#{p[0]}/.match(t.text)
  end

  # 一致した文字列が1つ以上あったら
  if position.size > 0
    # 出てきた単語順にソート
    p = position.sort {|a,b|
      a[1] <=> b[1]
    }
    # 最初に出てきた山名にだけリプライ
    reply = reply_pattern[p[0][0]].sample
    puts Time.now.to_s+" "+p[0][0]+" "+position[p[0][0]].to_s+t.id.to_s+" @"+t.from_user+" "+reply
    puts
    Twitter.update("@"+t.from_user+" "+reply, :in_reply_to_status_id => t.id)
  end
end

# 1つでもTLにツイートがあったら最後のを保存
if timeline.size != 0
  open(BASE_DIR+"/"+config["last_tweet_yaml"], "w") do |f|
    YAML.dump(timeline.first, f)
  end
end


#!/usr/bin/env ruby

require 'aws-sdk'

PUBLIC_DIR = 'public'

s3 = AWS::S3.new(s3_endpoint: "s3-ap-northeast-1.amazonaws.com")

#o = b.objects['foo.txt']
#o.write(:file => 'fsfs3_update.sh')

bucket = s3.buckets['tech.farend.jp']

Dir.chdir(PUBLIC_DIR)
files = Dir.glob('**/*')
files.each do |f|
  next unless File.file?(f)
  o = bucket.objects[f]
  o.write(:file => f)
  o.acl = :public_read
end

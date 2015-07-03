#!/usr/bin/env ruby

# Copyright (c) 2015 Kevin Wong <snarpel@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require "json"
require "net/http"
require "uri"

# get kit zip URL from the API
def get_kit_urls(os)

  # build number doesn't need to be valid. Instead, use a high number
  # Alternatively, get the build number from SparkleShare
  # https://ssl-download-crashlytics-com.s3.amazonaws.com/fabric/version.xml
  build_number = 1000000

  uri = URI.parse("https://kits.crashlytics.com/api/v3/sdk/kits/#{os}")
  uri.query = URI.encode_www_form({ :build_number => build_number })

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  response = http.request(Net::HTTP::Get.new(uri.request_uri))

  kits_json = JSON.parse(response.body)
  kit_urls = []

  kits_json.each do |k|

    uri = URI.parse(k['show-url'] + '/' + k['latest-release-identifier'])
    uri.query = URI.encode_www_form({ :build_number => build_number })
    # puts uri

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(Net::HTTP::Get.new(uri.request_uri))

    kit_json = JSON.parse(response.body)
    kit_urls << kit_json['artifact-url']
  end

  return kit_urls
end

# Download all zips
def download_kits(os, kit_urls)
  zip_dir = "_kits/#{os}"
  kit_dir = "#{os}_kits"
  `mkdir -p _kits; rm -rf #{zip_dir}; mkdir -p #{zip_dir}`
  kit_urls.each do |k|
    `cd #{zip_dir}; curl -O #{k}`
  end
end

# Extract zips to relevant directory
def extract_kit_zips(os)
  zip_dir = "_kits/#{os}"
  kit_dir = "#{os}_kits"

  `rm -rf #{kit_dir}; mkdir -p #{kit_dir}`
  Dir["#{zip_dir}/*.zip"].each do |k|
    mac_zip = `zipinfo -1 #{k} | grep __MACOSX`.length > 0
    if mac_zip
      output_dir = kit_dir + "/" + File.basename(k).sub(/\.zip$/i, '')
      `unzip -u #{k} -x "__MACOSX/*" -d #{output_dir}`
    else
      `unzip -u #{k} -d #{kit_dir}/`
    end
  end

end

puts "Retrieving kits information..."
ios_kit_urls = get_kit_urls('ios')
mac_kit_urls = get_kit_urls('mac')

puts "Downloading kits..."
download_kits('ios', ios_kit_urls)
download_kits('mac', mac_kit_urls)

puts "Extracting kits..."
extract_kit_zips('ios')
extract_kit_zips('mac')

# rubocop:disable Style/StringLiterals
# frozen_string_literal: true

require 'rest-client'
require 'json'
require 'sequel'

OWNER = ARGV[0]
REPO = ARGV[1]
TOKEN = ARGV[2]

REPO_IMAGE_FOLDER_MAPPING = {
  "datatracker" => "datatracker",
  "mailarch" => "mailarch",
  "xml2rfc" => "ietfdb"
}.freeze

REPO_DB_MAPPING = {
  "datatracker" => "ietfdb",
  "mailarch" => "ietfdb",
  "xml2rfc" => "xml2rfc"
}.freeze

DB_URL = "sqlite://../trac-svn-db/trac/#{REPO_DB_MAPPING[REPO]}/db/trac.db"
BASE_URL = "https://raw.githubusercontent.com/ietf-tools/svntrac-converted-attachments/main/#{REPO_IMAGE_FOLDER_MAPPING.fetch(REPO, REPO)}/attachments"
COMMENT = "The attachments for these issues were lost in trac before the transition to github, \
and cannot be recovered. If the issue is still relevant, and the attachments can be \
reconstructed, please add them as new comments."

def attachment_path(id, filename)
  folder_name = Digest::SHA1.hexdigest(id)
  parent_folder_name = folder_name[0..2]
  hashed_filename = Digest::SHA1.hexdigest(filename)
  file_extension = File.extname(filename)

  "#{parent_folder_name}/#{folder_name}/#{hashed_filename}#{file_extension}"
end

def issue_deleted?(issue_number)
  url = "https://api.github.com/repos/#{OWNER}/#{REPO}/issues/#{issue_number}"
  RestClient.get(url)
  false
rescue RestClient::Gone
  true
end

def invalid_url?(url)
  RestClient.head(url)
  false
rescue RestClient::NotFound
  true
end

def add_comment(issue_number)
  return if issue_deleted?(issue_number)

  url = "https://api.github.com/repos/#{OWNER}/#{REPO}/issues/#{issue_number}/comments"
  RestClient.post(url,
                  { body: COMMENT }.to_json,
                  {
                    "Authorization" => "token #{TOKEN}",
                    "Accept" => "application/vnd.github.v3+json"
                  })
end

db = Sequel.connect(DB_URL)

total_count = db[:attachment].count
invalid_count = 0
invalid_urls = {}

puts "Total Attachments: #{total_count}"

db[:attachment].each_with_index do |attachment, index|
  type = attachment[:type]
  next if type == "wiki"

  id = attachment[:id]
  file_name = attachment[:filename]

  url = "#{BASE_URL}/#{type}/#{attachment_path(id, file_name)}"

  if invalid_url?(url)
    add_comment(id) unless invalid_urls.key?(id)

    invalid_count += 1
    invalid_urls[id] ||= []
    invalid_urls[id] << url
  end

  puts "Processed: #{index + 1}/#{total_count}"
end

puts "\n\nvalid count: #{total_count}, invalid count: #{invalid_count}\n\n"
puts "Invalid Urls:"

invalid_urls.each do |id, urls|
  puts "  #{id}:"

  urls.each do |url|
    puts "    #{url}"
  end
end

# rubocop:enable Style/StringLiterals

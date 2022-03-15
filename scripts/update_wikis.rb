# frozen_string_literal: true

require 'English'

OLD_VALUE = ARGV[0] # 'https://github.com/ietf-svn-conversion/datatracker'
NEW_VALUE = ARGV[1] # 'https://github.com/ietf-tools/datatracker'
COMMIT_AUTHOR = ARGV[2]

def execute_command(command)
  `#{command}`
  $CHILD_STATUS
end

Dir.glob('*.md') do |filename|
  current_content = File.read(filename)
  updated_content = current_content.gsub(OLD_VALUE, NEW_VALUE)

  File.open(filename, 'w') do |file|
    file.puts(updated_content)
  end
end

unless execute_command('git add .').success?
  puts('ERROR at git-add !!!')
  exit(1)
end

commit_command = "git commit -m \"Updated wiki links\" --author \"#{COMMIT_AUTHOR}\""
unless execute_command(commit_command).success?
  puts('ERROR at git-commit !!!')
  exit(1)
end

unless execute_command('git push').success?
  puts('ERROR at push !!!')
  exit(1)
end

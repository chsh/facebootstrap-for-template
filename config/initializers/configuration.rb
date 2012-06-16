# place this file under Rails.root/config/initializers/configuration.rb
#
# load configurations from Rails.root/config/environments.
#
# load order is:
# 0. application.rb
# 1. #{Rails.env}.rb
# 2. app(1|2).rb
# 3. app(1|2)_#{rails.env}.rb
# 4. app(1|2)_local.rb
# 5. local.rb

ef = File.join(Rails.root, 'config', 'environments')
environments = Dir.glob("#{ef}/*.rb").map { |f| File.basename(f).gsub(/\.rb$/, '') }
environments_regex = "(#{environments.join('|')})"

path = File.join(Rails.root, 'config', 'settings')

files = Dir.glob("#{path}/*.rb")

loads = [[], [], [], [], [], []]
files.each do |file|
  bn = File.basename(file)
  case bn
  when 'application.rb' then loads[0] << file
  when /^.+_#{Rails.env}\.rb$/ then loads[3] << file
  when /^.+_local\.rb$/ then loads[4] << file
  when 'local.rb' then loads[5] << file
  when "#{Rails.env}.rb" then loads[1] << file
  else
    loads[2] << file unless bn =~ /^(.+_)?#{environments_regex}\.rb$/
  end
end

loads.each do |slot|
  slot.sort.each do |f|
    Kernel.load f
  end
end

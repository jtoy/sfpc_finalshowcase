puts Dir.pwd
to_check = Dir.pwd
dirs = Dir.entries(to_check).select {|entry| puts entry; File.directory? File.join(to_check,entry) and !(entry[0] =='.') }
loop do
  dirs.each do |dir|
    cmd = " timeout 60 processing-java --sketch=#{File.join(to_check,dir)} --run"
    puts cmd
    `#{cmd}`
  end
end

bginfo_home = '/Users/Shared/BGInfo'

ruby_block 'set BGInfo owner to autoLoginUser' do
  block do
    loginwindow_plist = '/Library/Preferences/com.apple.loginwindow'
    auto_login_user = "defaults read #{loginwindow_plist} autoLoginUser"
    node.default['bginfo']['owner'] = shell_out!(auto_login_user).stdout.strip
  end
end

include_recipe 'homebrew'
package 'imagemagick'
package 'ghostscript'

git bginfo_home do
  repository 'http://apexlabgit.corp.microsoft.com/mike/BG-Info-Mac.git'
end

directory bginfo_home do
  owner lazy { node['bginfo']['owner'] }
  group 'staff'
end

bginfo_home_contents = %w(bginfo.command
                          macstorage.sh
                          final_bg.gif
                          storage.rb)

bginfo_home_contents.each do |file|
  file "#{bginfo_home}/#{file}" do
    owner lazy { node['bginfo']['owner'] }
    group 'staff'
  end
end

launchd 'com.microsoft.bginfo' do
  program "#{bginfo_home}/bginfo.command"
  start_calendar_interval 'Hour' => 05, 'Minute' => 0
  run_at_load true
  type 'agent'
  action :enable
end
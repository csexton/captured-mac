require 'fileutils'

desc "Build the test installer package"
task :package do
  system %{codesign -f -v -s "3rd Party Mac Developer Application: Christopher Sexton" "build/App Store Release/Captured.app"}
  system %{productbuild --component "build/App Store Release/Captured.app" "/Applications" --sign "3rd Party Mac Developer Application: Christopher Sexton" "captured.pkg"}
end

desc "Install the test installer package"
task :install_package do
  system %{sudo installer -store -pkg ./captured.pkg -target /}
end

desc "Upload the Release to codeography.com"
task :upload do
  puts org_dir = FileUtils.pwd
  FileUtils.cd "build/Release"
  system %{zip -r Captured.zip Captured.app}
  FileUtils.cd org_dir
  system %{scp build/Release/Captured.zip captured.codeography.com:captured.codeography.com/captured.zip}
  system %{echo "http://captured.codeography.com/captured.zip" | pbcopy}
end

namespace :defaults do
  desc "Read the defaults settings"
  task :read do
    system %{defaults read com.codeography.captured-mac}
  end

  desc "Clear all the defaults settings"
  task :delete do
    system %{defaults delete com.codeography.captured-mac}
  end
  desc "Use the original image as the imgur key"
  task :key do
    system %{defaults write com.codeography.captured-mac ImagurKey original}
  end

  desc "Clear the first run bit"
  task :firstrun do
    system %{delete com.codeography.captured-mac FirstRun}
  end
end

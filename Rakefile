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

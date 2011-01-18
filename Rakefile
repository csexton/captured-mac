

desc "Build the test installer package"
task :package do 
  system %{codesign -f -v -s "3rd Party Mac Developer Application: Christopher Sexton" "build/App Store Release/Captured.app"}
  system %{productbuild --component "build/App Store Release/Captured.app" "/Applications" --sign "3rd Party Mac Developer Application: Christopher Sexton" "captured.pkg"}
end

desc "Install the test installer package"
task :install_package do
  system %{sudo installer -store -pkg ./captured.pkg -target /}
end

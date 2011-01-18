

desc "Build the test installer package"
task :package do 
  system %{codesign -f -v -s "3rd Party Mac Developer Application: Christopher Sexton" "build/App Store Release/Captured.app"}
  system %{productbuild --component "build/App Store Release/Captured.app" "/Applications" --sign "3rd Party Mac Developer Application: Christopher Sexton" "captured.pkg"}
end

desc "Install the test installer package"
task :install_package do
  system %{sudo installer -store -pkg ./captured.pkg -target /}
end

desc "Upload the Debug"
task :scp_debug do
  system %{scp build/Debug/Captured.zip captured.codeography.com:captured.codeography.com/captured-debug.zip}
  system %{echo "http://captured.codeography.com/captured-debug.zip" | pbcopy}
end

desc "Upload the Release"
task :scp_release do
  # XXX This needs to cd to the right dir so we dont' make nested folders in
  # the zip
  #
  # cd build/Release
  system %{zip -r build/Release/Captured.zip build/Release/Captured.app}
  # cd ../..
  system %{scp build/Release/Captured.zip captured.codeography.com:captured.codeography.com/captured.zip}
  system %{echo "http://captured.codeography.com/captured.zip" | pbcopy}
end

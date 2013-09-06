Given /^a target source named "(.*)" with:$/ do |src_name, content|
  create_src_file(src_name, content)
end

When /^I successfully run `(.*)` on noarch$/ do |abbrev_cmd|
  cmd, src = abbrev_cmd.split
  run_adlint(cmd, src, "-t", "noarch_traits.yml")
end

Then /^the output should exactly match with:$/ do |mesg_table|
  $all_output.lines.size.should == mesg_table.hashes.size
  $all_output.each_line.zip(mesg_table.hashes).each do |line, row|
    if row
      line.should =~ /#{row[:line]}:#{row[:column]}:.*:.*:#{row[:mesg]}/
    else
      line.should =~ /::.*:/
    end
  end
end

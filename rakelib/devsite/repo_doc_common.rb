class RepoDocCommon
  def cmd line
    puts line
    output = `#{line}`
    puts output
    output
  end

  def case_insensitive_fs?
    dir = create_tmp_dir "fs-case-sensitivity"
    File.write dir + "test", "hello world!"
    sensitive = File.exists? dir + "TEST"
    safe_remove_dir dir
    sensitive
  end

  def case_insensitive_check!
    if case_insensitive_fs?
      puts "You are running on a case-insensitive file system."
      puts "Documentation built on this file system may be incorrect."
      puts "https://github.com/googleapis/google-cloud-ruby/wiki/Working-with-documentation-on-a-case-insensitive-file-system"
      puts "Are you sure you want to continue? [y/N]"
      answer = STDIN.gets.strip.downcase
      return true if answer != "y"
    end
    false
  end
end

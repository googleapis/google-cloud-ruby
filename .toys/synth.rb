desc "Run synthtool"

flag :all, desc: "Run in all subdirectories with a synth.py"
flag :update, desc: "Update synthtool only and do not run"
flag :update_local, "--update-local=PATH", desc: "Update synthtool from a local path only and do not run."
flag :no_upgrade, desc: "Do not upgrade when installing"

remaining_args :synth_args

include :exec
include :terminal

def run
  upgrade_flag = no_upgrade ? "" : "--upgrade"
  if update_local
    Kernel.exec "python3 -m pip install --user #{upgrade_flag} #{update_local}"
  elsif update
    Kernel.exec "python3 -m pip install --user #{upgrade_flag} git+https://github.com/googleapis/synthtool.git"
  elsif all
    run_all
  else
    Kernel.exec "python3 -m synthtool -- " + synth_args.join(" ")
  end
end

def run_all
  paths = Dir.glob("*/synth.py").sort
  count = paths.size
  paths.each_with_index do |path, index|
    dir = File.dirname path
    Dir.chdir dir do
      puts "Running synthtool in #{dir} (#{index+1}/#{count})...", :bold
      exec ["python3", "-m", "synthtool", "--"] + synth_args
    end
  end
end

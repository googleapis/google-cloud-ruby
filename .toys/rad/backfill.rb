desc "Backfill cloud-rad upload"

include :exec, e: true

def run
  cmd ["release", "perform", "--force-republish", "--enable-rad"]
  cmd << "-#{'q' * (-verbosity)}" if verbosity < 0
  cmd << "-#{'v' * verbosity}" if verbosity > 0
  exec_tool cmd
end

def javascripts
  # Remove jquery as we already load jquery in the site.
  super - ["js/jquery.js"] + ["js/devsite-forwarder.js"]
end

def javascripts
  # Remove jquery as we already load jquery in the site.
  super - ["js/jquery.js"]
end

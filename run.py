with open("gapic-docker.txt", "r") as f:
  for line in f:
    line = line.replace('./', '').replace('\n', '')
    __import__(line + '.synth')

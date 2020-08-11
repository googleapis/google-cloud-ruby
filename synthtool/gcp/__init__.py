class GAPICMicrogenerator:
  def __init__(self):
    pass

  def typescript_library(self, service, version, proto_path, generator_args=None, **kwargs):
    if generator_args is None:
      generator_args = {}
    for key, value in generator_args.items():
      if key == "grpc-service-config":
        continue
      key = key.replace('-', '_')
      print(f"set {key} \"{value}\"|{proto_path}:%nodejs_gapic_library")

  def ruby_library(self, service, version, proto_path=None, generator_args=None, **kwargs):
    if generator_args is None:
      generator_args = {}
    if proto_path is None:
      proto_path = f"google/cloud/{service}/{version}"
    for key, value in generator_args.items():
      if key == "grpc-service-config":
        continue
      key = key.replace('-', '_')
      print(f"set {key} \"{value}\"|{proto_path}:%ruby_gapic_library")

class GAPICBazel:
  def __init__(self):
    pass

class CommonTemplates:
  def __init__(self):
    pass

  def node_library(self, **kwargs):
    pass

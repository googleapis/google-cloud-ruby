# Post-quantum Cryptography (PQC) Support

To protect against the "Store Now, Decrypt Later" attack, Google Cloud is implementing Post-Quantum Cryptography (PQC) across its services.
For more information on Google Cloud's approach, see [Post-Quantum Cryptography on Google Cloud](https://cloud.google.com/security/resources/post-quantum-cryptography?hl=en).

## Post-quantum key exchange

Google Cloud client libraries support post-quantum key exchange using the X25519MLKEM768 hybrid mechanism for TLS 1.3 connections.

The Ruby client libraries don't implement TLS themselves. Each transport relies on a TLS library, and when that library offers `X25519MLKEM768`, supported Google Cloud services negotiate it automatically. No application code changes are required. Whether a connection uses PQC depends on these versions:

| Transport | TLS library | Requirement for PQC |
| ----- | ----- | ----- |
| gRPC | BoringSSL, embedded in the `grpc` gem | `grpc` 1.83.0 or later |
| REST | The OpenSSL library that Ruby's `openssl` extension is linked against | OpenSSL 3.5.0 or later |

Most `google-cloud-*` libraries use gRPC by default, and many also accept `transport: :rest`. Libraries built on `google-apis-core`, such as `google-cloud-storage` and `google-cloud-bigquery`, always use REST.

If the TLS library doesn't offer `X25519MLKEM768`, the connection silently falls back to a classical group such as X25519. Requests still succeed and are still encrypted, but the connection isn't protected against "Store Now, Decrypt Later" attacks. If your workload requires PQC, check your environment as described in the following sections.

### gRPC transport

[gRPC 1.83.0](https://github.com/grpc/grpc/releases/tag/v1.83.0) made post-quantum key exchange the default. On CRuby, the `grpc` gem embeds its own BoringSSL ([`extconf.rb`](https://github.com/grpc/grpc/blob/v1.84.0/src/ruby/ext/grpc/extconf.rb#L99)), so the host's OpenSSL version doesn't affect gRPC connections.

`gapic-common` 1.4.0 and later require `grpc` 1.83 or later. However, your application can still load an older `grpc` with an older `gapic-common`, for example if your `Gemfile.lock` predates these releases or another gem restricts `grpc`. To require a PQC-capable `grpc` in your application, add this line to your `Gemfile`:

```ruby
gem "grpc", ">= 1.83"
```

With this line, Bundler won't select an older `grpc`. If your `Gemfile.lock` has one, the next `bundle install` updates it, or reports a conflict if another gem requires an older version. To check the version your application loads:

```
bundle exec ruby -e 'require "grpc"; puts GRPC::VERSION'
```

The `grpc` gem doesn't expose the negotiated group to Ruby code. To check it, use a [packet capture](#verifying-with-a-packet-capture).

### REST transport

By default, REST clients use Ruby's `openssl` extension for TLS. For example, clients created with `transport: :rest` send requests through Faraday's `Net::HTTP` adapter ([`client_stub.rb`](https://github.com/googleapis/ruby-core-libraries/blob/gapic-common/v1.5.0/gapic-common/lib/gapic/rest/client_stub.rb#L86-L92)). OpenSSL 3.5.0 changed its default TLS key shares to offer `X25519MLKEM768` ([OpenSSL 3.5 release notes](https://github.com/openssl/openssl/blob/openssl-3.5/NEWS.md)), so REST connections use PQC when Ruby is linked against OpenSSL 3.5.0 or later, unless your system's OpenSSL configuration sets its own group list.

A gem can't require a particular OpenSSL library version. The version comes from your operating system, your container base image, or how Ruby was built. To check the version Ruby uses at runtime:

```
ruby -ropenssl -e 'puts OpenSSL::OPENSSL_LIBRARY_VERSION'
```

| Environment | OpenSSL | PQC over REST |
| ----- | ----- | ----- |
| Debian 13 (trixie), including `ruby:<version>-trixie` images | 3.5 | Yes |
| Ubuntu 26.04 LTS | 3.5 | Yes |
| Debian 12 (bookworm), including `ruby:<version>-bookworm` images | 3.0 | No |
| Ubuntu 24.04 LTS | 3.0 | No |

#### Checking the negotiated group

[`OpenSSL::SSL::SSLSocket#group`](https://docs.ruby-lang.org/en/4.0/OpenSSL/SSL/SSLSocket.html#method-i-group) returns the group that a connection negotiated. It requires version 4.0 or later of the `openssl` gem, built against OpenSSL 3.2 or later. Ruby 4.0 includes this version. On earlier versions of Ruby, run `gem install openssl` first. The following script connects with the same default key exchange settings that the REST transport uses:

```ruby
require "openssl"
require "socket"

host = "storage.googleapis.com"
context = OpenSSL::SSL::SSLContext.new
context.set_params
socket = OpenSSL::SSL::SSLSocket.new TCPSocket.new(host, 443), context
socket.hostname = host
socket.sync_close = true
socket.connect
puts socket.group # prints X25519MLKEM768
socket.close
```

If the output is `X25519MLKEM768`, the connection used PQC. If the output is `x25519`, it fell back to classical key exchange.

### Verifying with a packet capture

A packet capture shows the group that your application's connections negotiate, for gRPC and REST, without changes to your application. This works because the TLS 1.3 ServerHello message, which names the group that the server selected, isn't encrypted ([RFC 8446](https://www.rfc-editor.org/rfc/rfc8446#section-2)). For example, on Linux, run [`tshark`](https://www.wireshark.org/docs/man-pages/tshark.html) in a separate terminal before your application connects, because gRPC clients reuse an open connection for later requests:

```
sudo tshark -i any -p -f "tcp port 443" -Y tls.handshake.extensions_key_share_group -T fields -e tcp.stream -e tls.handshake.extensions_server_name -e tls.handshake.extensions_key_share_group
```

After it prints `Capturing on 'any'`, start your application. Each connection prints two lines with the same number in the first column. The line with a hostname lists the groups that your application sent key shares for, and the other line shows the group that the server selected. For example, a gRPC call followed by a REST call on Debian 12 prints:

```
0       secretmanager.googleapis.com    4588,29
0               4588
1       secretmanager.googleapis.com    29
1               29
```

| Value | Group | Post-quantum |
| ----- | ----- | ----- |
| 4588 | X25519MLKEM768 | Yes |
| 29 | x25519 | No |

In this example, the gRPC connection used `X25519MLKEM768`, and the REST connection used `x25519`, because Debian 12's OpenSSL 3.0 doesn't support `X25519MLKEM768`. For other values, see the [IANA TLS Supported Groups registry](https://www.iana.org/assignments/tls-parameters/tls-parameters.xhtml#tls-parameters-8).

If your application runs in a container, run the command without `sudo` in another container that includes `tshark` and shares the application's network namespace, for example one started with `docker run --network container:<name>`. If your application uses a proxy, replace `443` with the proxy's port. If the proxy terminates TLS, the capture shows your application's handshake with the proxy, not with Google.

To capture on a server that doesn't have `tshark`, record the traffic with `sudo tcpdump -i any -p -w tls.pcap "tcp port 443"`. Then read the file with `tshark -r tls.pcap` and the same `-Y`, `-T`, and `-e` options, or open it in Wireshark.

### Disabling post-quantum key exchange

You might need to disable PQC temporarily. For example, a firewall, proxy, or other middlebox might mishandle the larger TLS ClientHello that hybrid key shares produce.

#### REST

Restrict the offered groups with an OpenSSL configuration file. For details, see the `Groups` command in [`SSL_CONF_cmd`](https://docs.openssl.org/3.5/man3/SSL_CONF_cmd/) and the `system_default` section in [`config(5)`](https://docs.openssl.org/3.5/man5/config/).

```
openssl_conf = openssl_init

[openssl_init]
ssl_conf = ssl_sect

[ssl_sect]
system_default = system_default_sect

[system_default_sect]
Groups = X25519:secp256r1:secp384r1
```

```
OPENSSL_CONF=/path/to/classical-only.cnf bundle exec ruby app.rb
```

This setting affects every OpenSSL connection in the process, not only Google Cloud clients. `OPENSSL_CONF` also replaces your system's default OpenSSL configuration file, which `ruby -ropenssl -e 'puts OpenSSL::Config::DEFAULT_CONFIG_FILE'` prints. To keep that file's existing settings, copy it and merge the settings above into the copy.

#### gRPC

The `grpc` gem has no setting to restrict key exchange groups. `GRPC::Core::ChannelCredentials` accepts only certificates and keys ([`rb_channel_credentials.c`](https://github.com/grpc/grpc/blob/v1.84.0/src/ruby/ext/grpc/rb_channel_credentials.c#L132-L143)), and the embedded BoringSSL ignores OpenSSL configuration files ([`conf.h`](https://boringssl.googlesource.com/boringssl/+/2b44a3701a4788e1ef866ddc7f143060a3d196c9/include/openssl/conf.h#95)). Clients that support only gRPC have no setting to disable PQC. If you must disable PQC for a client that supports REST, create the client with `transport: :rest` and restrict groups as described in the previous section:

```ruby
require "google/cloud/secret_manager"

client = Google::Cloud::SecretManager.secret_manager_service transport: :rest
```

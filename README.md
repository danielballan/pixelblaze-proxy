# Pixelblaze over HTTPS

## Approach

Rewrite the WebSocket URLs in the Pixelblaze web application from `ws://...:81`
to `wss://...:443/websocket`. Proxy requests to `wss://...:443/websocket` to
`ws://...:81` on the backend.

## Setup

Place this repository at `/etc/pixelblaze-proxy`.

**Edit this line in `pixelblaze-proxy.container` to match your Pixelblaze IP.**

```
Environment=PIXELBLAZE_IP=192.168.86.250
```

Build caddy with [custom replace-response][] plugin. The
[official replace-response][] plugins requests that the backend send
uncompressed responses. Pixelblaze unconditionally sends gzipped responses,
likely as a measure to save both compute and memory.

```
podman build -t localhost/caddy-for-pixelblaze:latest -f Containerfile .
```

Configure a quadlet.

```
ln -s /etc/pixelblaze-proxy/pixelblaze-proxy.container /etc/containers/systemd/
```

```
systemctl daemon-reload
systemctl start pixelblaze-proxy
systemctl status pixelblaze-proxy
```

Use [Tailscale Services][] to route traffic. All application traffic is secure,
over `443`. Port `80` provides an HTTP→HTTPS redirect as a convenience.

```
tailscale serve --service=svc:leds --https=443 http://127.0.0.1:8000
tailscale serve --service=svc:leds --http=80 http://127.0.0.1:8001
```

[Tailscale Services]: https://tailscale.com/kb/1552/tailscale-services
[official replace-response]: https://github.com/caddyserver/replace-response
[custom replace-response]: https://github.com/danielballan/replace-response/tree/gzipped-upstream

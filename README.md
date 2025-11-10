# docker-supermicro-smb

Container that facilitates mounting virtual media for older Supermicro BMCs.

## Running

Expose the classic SMB ports and bind-mount the directory containing your ISO files into `/srv/isos` (the volume path baked into the image):

```bash
docker run -d \
  --name supermicro-smb \
  -p 137:137/udp \
  -p 138:138/udp \
  -p 139:139 \
  -p 445:445 \
  -v /path/to/local/isos:/srv/isos:ro \
  supermicro-smb
```

### Notes

- `/srv/isos` must contain the ISO images you want the Supermicro BMC to access; the container runs Samba in read-only mode for that share.
- The bundled `smb.conf` enforces SMBv1/NTLM settings required by older IPMI/BMC firmware. Replace `smb.conf` during the build if you need different settings.
- SMBv1, LANMAN, and NTLMv1 are cryptographically weak and susceptible to relay/downgrade attacks; isolate the container on a dedicated management network or restrict access with firewall rules so only the intended BMC can reach UDP 137/138 and TCP 139/445.

## Docker Compose


```yaml
services:
  supermicro-smb:
    image: ghcr.io/veloslab/supermicro-smb:latest
    container_name: supermicro-smb
    restart: unless-stopped
    ports:
      - "137:137/udp"
      - "138:138/udp"
      - "139:139"
      - "445:445"
    volumes:
      - /path/to/local/isos:/srv/isos:ro
```

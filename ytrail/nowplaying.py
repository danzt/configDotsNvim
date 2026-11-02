#!/usr/bin/env python3
"""Print 'title<TAB>paused' for the ytrail mpv, or nothing if it is not running. Fast and silent."""
import json, os, socket
sock = os.path.expanduser("~/.local/state/ytrail/mpv.sock")
try:
    s = socket.socket(socket.AF_UNIX); s.settimeout(0.3); s.connect(sock)
    s.sendall(b'{"command":["get_property","media-title"],"request_id":1}\n{"command":["get_property","pause"],"request_id":2}\n')
    got, buf = {}, b""
    while len(got) < 2:
        buf += s.recv(65536)
        for line in buf.split(b"\n")[:-1]:
            try:
                m = json.loads(line)
                if m.get("request_id") in (1, 2): got[m["request_id"]] = m.get("data")
            except ValueError:
                pass
        buf = buf.split(b"\n")[-1]
    if got.get(1): print(f"{got[1]}\t{'1' if got.get(2) else '0'}")
except Exception:
    pass

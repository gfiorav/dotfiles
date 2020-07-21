set -x LIBGL_ALWAYS_INDIRECT 1
set -x DISPLAY (awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null)

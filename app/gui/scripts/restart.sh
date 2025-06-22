#!/bin/bash

restart_ags() {
    echo "🔁 Restarting AGSv1..."
    pkill agsv1 && nohup agsv1 >/dev/null 2>&1 &
}

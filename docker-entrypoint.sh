#!/bin/bash
set -e
# Hardcoded Internal Port
PORT=8888
SECRET=${SECRET}
DOMAIN=${DOMAIN:-"cdnjs.cloudflare.com"}

if [ -z "$SECRET" ]; then
    echo "No SECRET found. Generating a new one..."
    SECRET=$(head -c 16 /dev/urandom | hexdump -ve '1/1 "%.2x"')
    
    # Try to persist to .env if mounted
    if [ -f /data/.env ]; then
        echo "Updating .env file with new SECRET..."
        
        # DEBUG: Check permissions
        echo "DEBUG: .env permissions: $(ls -l /data/.env)"
        echo "DEBUG: Current user: $(id)"

        # Use temp file + cat to preserve file ownership/permissions on host
        if grep -q "^SECRET=" /data/.env; then
            # More robust regex: match SECRET= followed by anything (or nothing)
            sed "s/^SECRET=.*$/SECRET=$SECRET/" /data/.env > /tmp/.env.tmp
            cat /tmp/.env.tmp > /data/.env
            rm /tmp/.env.tmp
        else
            # If SECRET= not found, append it
            echo "SECRET=$SECRET" >> /data/.env
        fi
        
        # Verify persistence
        if grep -q "$SECRET" /data/.env; then
            echo "✅ Successfully saved SECRET to .env"
        else
            echo "⚠️  Failed to save SECRET to .env"
            echo "DEBUG: File content after write attempt:"
            cat /data/.env
        fi
    else
        echo "⚠️  .env file not mounted at /data/.env. Secret will be ephemeral."
    fi
    
    echo "Generated Secret: $SECRET"
fi

# Check for HOST_PORT in .env, default to 8443 if missing
if [ -f /data/.env ]; then
    # grep -q returns 0 if found
    if ! grep -q "^HOST_PORT=" /data/.env; then
        echo "Updating .env with HOST_PORT=443 (default)..."
        echo "HOST_PORT=443" >> /data/.env
    elif grep -q "^HOST_PORT=$" /data/.env; then
        echo "Updating empty HOST_PORT in .env to 443..."
        sed "s/^HOST_PORT=$/HOST_PORT=443/" /data/.env > /tmp/.env.tmp
        cat /tmp/.env.tmp > /data/.env
        rm /tmp/.env.tmp
    fi
fi

# 1.1. Promote raw secret to FakeTLS if needed

if [ -z "$SECRET" ]; then
    FULL_SECRET="$SECRET"
fi

# 1. Promote raw secret to FakeTLS if needed
if [[ "$SECRET" != ee* ]]; then
    DOMAIN_HEX=$(echo -n "$DOMAIN" | hexdump -ve '/1 "%.2x"')
    FULL_SECRET="ee${SECRET}${DOMAIN_HEX}"
    echo "Promoted raw secret to FakeTLS secret: $FULL_SECRET"
else
    FULL_SECRET="$SECRET"
fi

# 2. Start MTG (Backgrounded)
CMD="mtg simple-run --antireplay-cache-size 1MB --concurrency 60000 --prefer-ip prefer-ipv4"
echo "Starting MTProxy..."
$CMD "0.0.0.0:$PORT" "$FULL_SECRET" &
MTG_PID=$!

# 3. Wait and Verify
sleep 2
if kill -0 "$MTG_PID" 2>/dev/null; then
    # It is running!
    # Determine full secret for display (re-using logic or just using FULL_SECRET since we calculated it)
    
    # Signal Handler
    cleanup() {
        echo "Stopping MTProto Proxy..."
        kill -TERM "$MTG_PID"
        wait "$MTG_PID"
        exit 0
    }
    trap cleanup SIGTERM SIGINT

    HOST_PORT=${HOST_PORT:-8443}
    PUBLIC_IP=${PUBLIC_IP:-$(curl -s ifconfig.me)} # Get public IP if not set

    TG_LINK="tg://proxy?server=${PUBLIC_IP}&port=${HOST_PORT}&secret=${FULL_SECRET}"
    TME_LINK="https://t.me/proxy?server=${PUBLIC_IP}&port=${HOST_PORT}&secret=${FULL_SECRET}"

    echo ""
    echo "------------------------------------------------------"
    echo "✅ MTProxy started successfully! (PID: $MTG_PID)"
    echo "Server: $PUBLIC_IP:$HOST_PORT"
    echo "Secret: $FULL_SECRET"
    echo "Domain: $DOMAIN"
    echo ""
    echo "🚀 Telegram Proxy Links:"
    echo "-----------------------"
    echo "Direct: $TG_LINK"
    echo "-----------------------"
    echo "https:  $TME_LINK"
    echo "------------------------------------------------------"
    
    # Wait for the process to exit (keep container alive)
    wait "$MTG_PID"
else
    echo "❌ MTProxy failed to start immediately."
    exit 1
fi

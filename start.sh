#!/bin/bash
# This script starts Visual Studio Code server accessible from anywhere

echo "my-code-server debian container"

# Check if PORT environment variable is set, default to 8585 if not
if [ -z "$PORT" ]; then
    echo "No PORT provided, using default port: 8000"
    PORT=8000
else
    echo "Using provided port: $PORT"
fi

# Check if HOST environment variable is set, default to 0.0.0.0 if not
if [ -z "$HOST" ]; then
    echo "No HOST provided, using default host: 0.0.0.0"
    HOST=0.0.0.0
else
    echo "Using provided host: $HOST"
fi

# Initialize the base command
CMD="code serve-web --host $HOST --port $PORT"

# Check for SERVER_DATA_DIR and add to command if set
if [ -n "$SERVER_DATA_DIR" ]; then
    echo "Using server data directory: $SERVER_DATA_DIR"
    CMD="$CMD --server-data-dir $SERVER_DATA_DIR"
fi

# Check for USER_DATA_DIR and add to command if set
if [ -n "$USER_DATA_DIR" ]; then
    echo "Using user data directory: $USER_DATA_DIR"
    CMD="$CMD --user-data-dir $USER_DATA_DIR"
fi

# Check for EXTENSIONS_DIR and add to command if set
if [ -n "$EXTENSIONS_DIR" ]; then
    echo "Using extensions directory: $EXTENSIONS_DIR"
    CMD="$CMD --extensions-dir $EXTENSIONS_DIR"
fi

# Check if TOKEN environment variable is set
if [ -z "$TOKEN" ]; then
    echo "No TOKEN provided, starting without token"
    CMD="$CMD --without-connection-token"
else
    echo "Starting with token: $TOKEN"
    CMD="$CMD --connection-token $TOKEN"
fi

# Execute the final command
echo "Executing: $CMD"
exec $CMD
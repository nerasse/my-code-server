#!/bin/bash

echo "my-code-server debian container"

# Handle UID/GID changes if environment variables are set
if [ -n "$PUID" ] || [ -n "$PGID" ]; then
  CURRENT_UID=$(id -u vscodeuser)
  CURRENT_GID=$(id -g vscodeuser)
  TARGET_UID=${PUID:-$CURRENT_UID}
  TARGET_GID=${PGID:-$CURRENT_GID}
  
  if [ "$CURRENT_UID" != "$TARGET_UID" ] || [ "$CURRENT_GID" != "$TARGET_GID" ]; then
    echo "Changing vscodeuser UID:GID from $CURRENT_UID:$CURRENT_GID to $TARGET_UID:$TARGET_GID"
    
    # Change GID if needed
    if [ "$CURRENT_GID" != "$TARGET_GID" ]; then
      groupmod -g $TARGET_GID vscodeuser
    fi
    
    # Change UID if needed
    if [ "$CURRENT_UID" != "$TARGET_UID" ]; then
      usermod -u $TARGET_UID vscodeuser
    fi
    
    # Fix permissions on home directory
    chown -R vscodeuser:vscodeuser /home/vscodeuser
    
    echo "UID/GID changed successfully"
  else
    echo "Using default UID:GID $CURRENT_UID:$CURRENT_GID"
  fi
else
  echo "Using default UID:GID $(id -u vscodeuser):$(id -g vscodeuser)"
fi

# Check if PORT environment variable is set, default to 8585 if not
if [ -z "$PORT" ]; then
  echo "No PORT provided, using default port: 8585"
  PORT=8585
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

# Check for SERVER_BASE_PATH and add to command if set
if [ -n "$SERVER_BASE_PATH" ]; then
  echo "Using server base path: $SERVER_BASE_PATH"
  CMD="$CMD --server-base-path $SERVER_BASE_PATH"
fi

# Check if SOCKET_PATH environment variable is set
if [ -n "$SOCKET_PATH" ]; then
  echo "Using socket path: $SOCKET_PATH"
  CMD="$CMD --socket-path $SOCKET_PATH"
fi

# Check if TOKEN environment variable is set
if [ -z "$TOKEN" ]; then
  echo "No TOKEN provided, starting without token"
  CMD="$CMD --without-connection-token"
else
  echo "Starting with token: $TOKEN"
  CMD="$CMD --connection-token $TOKEN"
fi

# Check if TOKEN_FILE environment variable is set
if [ -n "$TOKEN_FILE" ]; then
  echo "Using token file: $TOKEN_FILE"
  CMD="$CMD --connection-token-file $TOKEN_FILE"
fi

# Always accept the server license terms
echo "Server license terms accepted"
CMD="$CMD --accept-server-license-terms"

# Add verbosity options if set
if [ -n "$VERBOSE" ] && [ "$VERBOSE" = "true" ]; then
  echo "Running in verbose mode"
  CMD="$CMD --verbose"
fi

# Add log level if set
if [ -n "$LOG_LEVEL" ]; then
  echo "Using log level: $LOG_LEVEL"
  CMD="$CMD --log $LOG_LEVEL"
fi

# Add CLI data directory if set
if [ -n "$CLI_DATA_DIR" ]; then
  echo "Using CLI data directory: $CLI_DATA_DIR"
  CMD="$CMD --cli-data-dir $CLI_DATA_DIR"
fi

# Execute the final command as vscodeuser
echo "Executing: $CMD (as vscodeuser)"
exec su - vscodeuser -c "$CMD"

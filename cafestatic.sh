#!/bin/bash
set -e  # exit on error

# Jenkins working directory (workspace)
SRC_DIR="$WORKSPACE"   # project source code inside Jenkins
DEST_DIR="/var/www/html/cafestatic"
APACHE_CONF="/etc/apache2/sites-available/000-default.conf"

# 1. Create directory if not exists
if [ ! -d "$DEST_DIR" ]; then
    echo "Directory $DEST_DIR does not exist. Creating..."
    sudo mkdir -p "$DEST_DIR"
else
    echo "Directory $DEST_DIR already exists. Skipping creation."
fi

# 2. Copy website code into directory
echo "Copying files from $SRC_DIR to $DEST_DIR ..."
sudo rsync -av --delete "$SRC_DIR"/ "$DEST_DIR"/

# 3. Update Apache DocumentRoot in 000-default.conf
if grep -q "DocumentRoot" "$APACHE_CONF"; then
    echo "Updating DocumentRoot in $APACHE_CONF ..."
    sudo sed -i "s|DocumentRoot .*|DocumentRoot $DEST_DIR|g" "$APACHE_CONF"
else
    echo "DocumentRoot not found in $APACHE_CONF, adding entry ..."
    echo "DocumentRoot $DEST_DIR" | sudo tee -a "$APACHE_CONF"
fi

# 4. Restart Apache2
echo "Restarting Apache2..."
sudo systemctl restart apache2

echo "âœ… Deployment complete. Site is served from $DEST_DIR"

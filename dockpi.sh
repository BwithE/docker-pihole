#!/bin/bash

# Check if the "pihole" container is already running
if [ "$(docker ps -q -f name=pihole)" ]; then
    echo "Pi-hole Docker container is already running."
else
    # Check if there is a stopped "pihole" container
    if [ "$(docker ps -aq -f status=exited -f name=pihole)" ]; then
        # Start the stopped "pihole" container
        docker start pihole
        echo "Pi-hole Docker container started."
    else
        # Prompt user for Pi-hole password
        read -p "Enter Pi-hole password: " PIHOLE_PASSWORD

        # Create Pi-hole Docker container
        docker run -d \
          --name pihole \
          -p 53:53/tcp -p 53:53/udp \
          -p 80:80 \
          -p 443:443 \
          -e TZ="Your/Timezone" \
          -e WEBPASSWORD="$PIHOLE_PASSWORD" \
          --restart=unless-stopped \
          pihole/pihole:latest

        echo "Pi-hole Docker container is now running."
    fi
fi

# Get the IP address of the Pi-hole container
PIHOLE_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pihole)

# Set Ubuntu host machine DNS to Pi-hole container
sudo sed -i "s/nameserver .*/nameserver $PIHOLE_IP/" /etc/resolv.conf

echo "DNS set to Pi-hole container ($PIHOLE_IP)"

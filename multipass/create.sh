# --- GUI ---
multipass launch 22.04 -n gui -c 8 --d 100G -m 8G
multipass mount /Users/jjazzme/ gui:/home/ubuntu/jjazzme
multipass exec gui -- sudo bash -c 'cat << EOF > /home/ubuntu/init.sh

# ----- DOCKER SECTION -----
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ----- INSTALL SECTION -----
sudo apt update
sudo apt install -y ranger net-tools inetutils-traceroute avahi-daemon ca-certificates curl docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin ubuntu-desktop xrdp

# ----- SET PASSWORD SECTION -----
echo "SET PASSWORD FOR gui/ubuntu user"
sudo passwd ubuntu

# ----- SET ALIASES -----
echo "alias com=\"docker compose\"" >> /home/ubuntu/.bash_aliases
echo "alias swa=\"docker swarm\"" >> /home/ubuntu/.bash_aliases

EOF

sudo chmod +x /home/ubuntu/init.sh
/home/ubuntu/init.sh
sudo reboot
'


# --- TEST ---
multipass launch 22.04 -n test -c 2 -d 20G -m 1G
multipass mount /Users/jjazzme/IdeaProjects/k-ino test:/var/project
multipass exec test -- sudo bash -c 'cat << EOF > /home/ubuntu/init.sh

# ----- DOCKER SECTION -----
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ----- INSTALL SECTION -----
sudo apt update
sudo apt install -y ranger net-tools inetutils-traceroute avahi-daemon ca-certificates curl docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# ----- SET ALIASES -----
echo "alias com=\"docker compose\"" >> /home/ubuntu/.bash_aliases
echo "alias swa=\"docker swarm\"" >> /home/ubuntu/.bash_aliases

EOF

sudo chmod +x /home/ubuntu/init.sh
/home/ubuntu/init.sh
sudo reboot
'


# --- S0 ---
multipass launch 22.04 --name s0 --cpus 2 --disk 20G --memory 2G --network name=en1,mode=manual,mac="52:54:00:4b:ab:cd"
multipass mount /Users/jjazzme/IdeaProjects/k-ino/gate test:/var/project
multipass exec s0 -- sudo bash -c 'cat << EOF > /home/ubuntu/init.sh

# ----- ADDITIONAL NETWORK INTERFACE SECTION -----
cat << EOF1 > /etc/netplan/10-custom.yaml
network:
    version: 2
    ethernets:
        extra0:
            dhcp4: no
            match:
                macaddress: "52:54:00:4b:ab:cd"
            addresses: 
                - 213.138.66.178/29
            routes:
                -   to: 0.0.0.0/0
                    via: 213.138.66.177
            nameservers:
                addresses:
                    - 77.88.8.8
                    - 1.1.1.1
EOF1
sudo chmod 600 /etc/netplan/10-custom.yaml
sudo netplan apply

# ----- DOCKER SECTION -----
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ----- INSTALL SECTION -----
sudo apt update
sudo apt install -y ranger net-tools inetutils-traceroute avahi-daemon ca-certificates curl docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin ufw

# ----- SET UFW -----
# sudo ufw disable
# sudo ufw deny in on ens4
# sudo ufw allow out on ens4
# sudo ufw allow in on ens4 to any port 80 proto tcp
# sudo ufw allow in on ens4 to any port 443 proto tcp
# sudo ufw allow in on ens4 to any proto icmp
# sudo ufw allow in on ens4 to any port 33434:33534 proto udp
# sudo ufw --force enable

# ----- SET ALIASES -----
echo "alias com=\"docker compose\"" >> /home/ubuntu/.bash_aliases
echo "alias swa=\"docker swarm\"" >> /home/ubuntu/.bash_aliases

EOF

sudo chmod +x /home/ubuntu/init.sh
/home/ubuntu/init.sh
sudo reboot
'



multipass exex s0 -- sudo apt update
multipass exec s0 -- sudo bash -c 'cat << EOF > /etc/netplan/10-custom.yaml
network:
    version: 2
    ethernets:
        extra0:
            dhcp4: no
            match:
                macaddress: "52:54:00:4b:ab:cd"
            addresses: 
                - 213.138.66.178/29
            routes:
                -   to: 0.0.0.0/0
                    via: 213.138.66.177
            nameservers:
                addresses:
                    - 77.88.8.8
                    - 1.1.1.1
EOF'
multipass exec s0 -- sudo chmod 600 /etc/netplan/10-custom.yaml
multipass exec s0 -- sudo netplan apply
multipass exex s0 -- sudo apt update
multipass exec s0 apt sudo install -y ranger net-tools inetutils-traceroute avahi-daemon


# multipass transfer ./multipass/99-disable-network-config.cfg s1:/home/ubuntu/99-disable-network-config.cfg
# multipass exec s1 -- sudo mv /home/ubuntu/99-disable-network-config.cfg /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
# multipass exec s1 -- sudo rm -rf /etc/netplan
# multipass exec s1 -- sudo mkdir -p /etc/netplan
# multipass transfer ./multipass/s1-50-cloud-init.yaml s1:/home/ubuntu/01-netcfg.yaml
# multipass exec s1 -- sudo mv /home/ubuntu/01-netcfg.yaml /etc/netplan/01-netcfg.yaml
# multipass exec s1 -- sudo chmod 600 /etc/netplan/01-netcfg.yaml
# multipass exec s1 -- sudo netplan apply


multipass launch 24.04 --name s2 --cpus 2 --disk 20G --memory 2G

multipass launch 24.04 --name s3 --cpus 2 --disk 20G --memory 2G


# brew install qemu
# qemu-img create -f qcow2 gui.qcow2 100G

# multipass mount --uid-map 501:1000 --gid-map 20:1000 /Volumes/SPEED/KINO test:/mnt/kino
# multipass mount --uid-map 501:1000 --gid-map 20:1000 /Volumes/test/test/ test:/mnt/test/

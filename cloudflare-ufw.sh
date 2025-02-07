# 1. Get the existing Cloudflare IPs
old_cf_ips=$(ufw status | grep 'Cloudflare IP' | awk '{print $3}')

# 2. Get the latest Cloudflare IPs
new_cf_ips=$(curl -sw '\n' https://www.cloudflare.com/ips-v{4,6})

# 3. Delete the old IPs that are no longer in the new IP list
for ip in $old_cf_ips; do
    if ! echo "$new_cf_ips" | grep -qw "$ip"; then
        rule_number=$(ufw status numbered | grep "$ip" | sed -E 's/^\[ *([0-9]+)\].*/\1/')
        if [ -n "$rule_number" ]; then
            ufw --force delete "$rule_number"
        fi
    fi
done

# 4. Allow the new Cloudflare IPs
for cfip in $new_cf_ips; do
    ufw allow proto tcp from "$cfip" comment 'Cloudflare IP';
done

ufw reload > /dev/null

# OTHER EXAMPLE RULES
# Restrict to port 80 (tcp)
#for cfip in `curl -sw '\n' https://www.cloudflare.com/ips-v{4,6}`; do ufw allow proto tcp from $cfip to any port 80 comment 'Cloudflare IP'; done

# Restrict to port 443 (tcp & udp)
#for cfip in `curl -sw '\n' https://www.cloudflare.com/ips-v{4,6}`; do ufw allow from $cfip to any port 443 comment 'Cloudflare IP'; done

# Restrict to ports 80 & 443 (tcp)
#for cfip in `curl -sw '\n' https://www.cloudflare.com/ips-v{4,6}`; do ufw allow proto tcp from $cfip to any port 80,443 comment 'Cloudflare IP'; done

#!/bin/sh

: "${SSH_PRIVATE_KEY?SSH_PRIVATE_KEY is empty, please use up.sh}"
: "${SSH_PUBLIC_KEY?SSH_PUBLIC_KEY is empty, please use up.sh}"
: "${NODE_COUNT?NODE_COUNT is empty, please use up.sh}"

if [ ! -d ~/.ssh ]; then
  mkdir -m 700 ~/.ssh
fi

if [ ! -f ~/.ssh/id_rsa ]; then
  echo "${SSH_PRIVATE_KEY}" | perl -p -e 's/↩/\n/g' > ~/.ssh/id_rsa
  chmod 600 ~/.ssh/id_rsa
fi

if [ ! -f ~/.ssh/id_rsa.pub ]; then
  echo "${SSH_PUBLIC_KEY}" | perl -p -e 's/↩/\n/g' > ~/.ssh/id_rsa.pub
fi

# Remake known_hosts every time, to allow for changing node counts
echo > ~/.ssh/known_hosts
# Wait for all the hosts to report their hostnames.
# Using a string comparison to handle file not being present yet
while [ "$(wc -l /var/jepsen/shared/nodes | awk '{print $1;}')" != "${NODE_COUNT}" ]; do sleep 1; done
# Get nodes list
sort -V /var/jepsen/shared/nodes > ~/nodes
# Scan SSH keys
while read -r node; do
  # Wait for the host to come up correctly
  while ssh-keyscan -t rsa "${node}" 2>&1 | grep "Connection refused"; do sleep 1; done
  ssh-keyscan -t rsa "${node}" 2>/dev/null >> ~/.ssh/known_hosts
  ssh-keyscan -t ed25519 "${node}" 2>/dev/null >> ~/.ssh/known_hosts
done < ~/nodes

# TODO: assert that SSH_PRIVATE_KEY==~/.ssh/id_rsa

cat <<EOF
Welcome to Jepsen on Docker
===========================

Please run \`bin/console\` in another terminal to proceed.
EOF

# hack for keep this container running
tail -f /dev/null

#!/bin/bash

# Associate Elastic IP
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
EIP_ID=${EIP_ID}

aws ec2 associate-address \
--instance-id "$INSTANCE_ID" \
--allocation-id "$EIP_ID" \
--allow-reassociation \
--region us-east-1

# mount s3 bucket
mkdir /plex-data
%{ for BUCKET in BUCKETS ~}
mkdir /plex-data/${BUCKET}
s3fs ${BUCKET} -o iam_role="${IAM_ROLE}" -o use_cache=/tmp -o allow_other -o uid=0 -o mp_umask=002 -o multireq_max=5 -o ensure_diskfree=500 /plex-data/${BUCKET}
%{ endfor ~}

# attach and mount volume

VOLUME_ID=${VOLUME_ID}

aws ec2 attach-volume \
--device /dev/sdb \
--instance-id "$INSTANCE_ID" \
--volume-id $"$VOLUME_ID" \
--region us-east-1

while [ ! -e /dev/sdb ]; do echo waiting for /dev/sdb to attach; sleep 10; done

blkid --match-token TYPE=ext4 /dev/sdb || mkfs -t ext4 /dev/sdb

mkdir /plex
mount /dev/sdb /plex/

# persist mounts across reboots
# edit /etc/fstab
# format: device_name mount_point file_system_type fs_mntops fs_freq fs_passno
# example: /dev/sdb       /plex   ext4    defaults,nofail        0       0
echo "/dev/sdb       /plex   ext4    defaults,nofail        0       0" >> /etc/fstab

%{ for BUCKET in BUCKETS ~}
echo "s3fs#${BUCKET} /plex-data/${BUCKET} fuse _netdev,iam_role=${IAM_ROLE},use_cache=/tmp,allow_other,uid=0,mp_umask=002,multireq_max=5,ensure_diskfree=500" >> /etc/fstab
%{ endfor ~}

# # get claim token from parameter store
CLAIM_TOKEN=$(aws ssm get-parameter --name /${ENVIRONMENT}/plex/claim_token --region us-east-1 --with-decryption | jq -r ".Parameter.Value")

systemctl start docker
systemctl enable docker.service

cat >/etc/systemd/system/plex.service <<EOF 
[Unit]
Description=Plex container
After=docker.service plex.mount ${BUCKET_FSTAB_STRING}
Wants=network-online.target docker.socket
Requires=docker.socket

[Service]
Restart=always
ExecStartPre=/bin/bash -c '/usr/bin/docker container inspect plex 2> /dev/null || /usr/bin/docker run -d --name plex --network=host -h ${ENVIRONMENT} -e TZ="US/Central" -e PLEX_CLAIM="$CLAIM_TOKEN" -e PLEX_UID="0" -e PLEX_GID="0" -v /plex/config:/config -v /plex/transcode:/transcode -v /plex-data:/data plexinc/pms-docker'
ExecStart=/usr/bin/docker start -a plex
ExecStop=/usr/bin/docker stop -t 10 plex

[Install]
WantedBy=multi-user.target
EOF

systemctl start plex
systemctl enable plex.service

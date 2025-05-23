#!/bin/bash
apt-get update -y
snap install amazon-ssm-agent --classic
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

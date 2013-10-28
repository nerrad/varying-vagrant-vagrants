#ADD custom domains to virtual machine's hosts file
DOMAINS='wp.dev'
if ! grep -q "$DOMAINS" /etc/hosts
then
	DOMAINS=$(echo $DOMAINS)
	echo "127.0.0.1 $DOMAINS" >> /etc/hosts
fi
echo "-----------------------"
echo "Added custom domain"
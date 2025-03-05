# Lucky-Number


# Deploy
PUBLISHER_PROFILE=testnet && \
PUBLISHER_ADDR=6c2771d30dc669120be227362ea19141fa72ddc8bb5819409e4da54f0d09b573 && \
aptos move create-object-and-publish-package \
--address-name loterry_sc \
--named-addresses \
deployer=$PUBLISHER_ADDR \
--profile $PUBLISHER_PROFILE \
--assume-yes --included-artifacts none

# Upgrade
PUBLISHER_PROFILE=testnet && \
PUBLISHER_ADDR=1af912b16b224f4d59992177afdfc09508970e4a2e2b31cc7f88c82e001e24cd  && \
OBJECT_ADDR="0x266f94bcc5169136d461a92c5f19a7b5b455edcc67b1d89033d774810a267a53" && \
aptos move upgrade-object-package \
--object-address $OBJECT_ADDR \
--named-addresses \
loterry_sc=$OBJECT_ADDR,deployer=$PUBLISHER_ADDR --profile $PUBLISHER_PROFILE \
--assume-yes --included-artifacts none
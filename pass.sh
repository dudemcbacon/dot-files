#!/bin/sh
tmux new-window -n rpm -c ~/development/rpm_site
tmux new-window -n ps -c ~/development/provisioning_service
tmux new-window -n pcs -c ~/development/product-configuration-service
tmux new-window -n cps -c ~/development/customer-provisioning-service
tmux new-window -n bcr -c ~/development/business_change_router
tmux new-window -n lng -c ~/development/local-nerd-graph
tmux new-window -n eui -c ~/development/entitlements-admin
tmux new-window -n dui -c ~/development/deals-ui-nerdlet

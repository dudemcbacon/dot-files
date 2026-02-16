#!/bin/sh
tmux rename-window scratch
tmux new-window -n farnsworth -c ~/development/farnsworth
tmux new-window -n ps -c ~/development/provisioning_service
tmux new-window -n cps -c ~/development/customer-provisioning-service
tmux new-window -n pcs -c ~/development/product-configuration-service
tmux new-window -n cee -c ~/development/compact_entitlements_emitter/
tmux new-window -n cet -c ~/development/compact_entitlements_tester/
tmux new-window -n v2 -c ~/development/v2-entitlements-emitter/
tmux new-window -n chsc -c ~/development/customer-hierarchy-stream-consumer/
tmux new-window -n eui -c ~/development/entitlements-admin
tmux new-window -n alerts -c ~/development/pass-alerts-v2/
tmux new-window -n aws -c ~/development/pass-aws/
tmux new-window -n lng -c ~/development/local-nerd-graph

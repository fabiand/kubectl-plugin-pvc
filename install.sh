PLUGIN_PATH="$HOME/.kube/plugins/pvc/"
PLUGIN_CMD=pvc

mkdir -p "$PLUGIN_PATH"
install pvc.sh "$PLUGIN_PATH/$PLUGIN_CMD"

cat > "$PLUGIN_PATH/plugin.yaml" <<EOF
name: "pvc"
shortDesc: "Convenient way to create and populate PVs"
example: "create my-pvc 1Gi foo bar"
#command: "$(realpath $PLUGIN_PATH/$PLUGIN_CMD)"
command: "./$PLUGIN_CMD $PWD"
EOF

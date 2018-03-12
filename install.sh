PLUGIN_PATH="$HOME/.kube/plugins/pvc/"
PLUGIN_CMD=pvc

[[ -f "$PLUGIN_CMD" ]] || {
  echo "Pulling $PLUGIN_CMD from GitHub"
  curl -L -o $PLUGIN_CMD \
    https://raw.githubusercontent.com/fabiand/kubectl-plugin-pvc/master/pvc
}

mkdir -p "$PLUGIN_PATH"
cp $PLUGIN_CMD "$PLUGIN_PATH/$PLUGIN_CMD"
chmod +x "$PLUGIN_PATH/$PLUGIN_CMD"

cat > "$PLUGIN_PATH/plugin.yaml" <<EOF
name: "pvc"
shortDesc: "Convenient way to create and populate PVs"
example: "create my-pvc 1Gi foo bar"
command: "./$PLUGIN_CMD $PWD"
EOF

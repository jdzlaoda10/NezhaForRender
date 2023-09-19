#!/usr/bin/env bash

WEB_USERNAME=${WEB_USERNAME:-'admin'}
WEB_PASSWORD=${WEB_PASSWORD:-'password'}

generate_nezha() {
  cat > nezha.sh << EOF
#!/usr/bin/env bash

# 检测是否已运行
check_run() {
  [[ \$(pgrep -lafx nezha-agent) ]] && echo "哪吒客户端正在运行中" && exit
}

# 若哪吒三个变量不全，则不安装哪吒客户端
check_variable() {
  [[ -z "\${NEZHA_SERVER}" || -z "\${NEZHA_PORT}" || -z "\${NEZHA_KEY}" ]] && exit
}

# 下载最新版本 Nezha Agent
download_agent() {
  if [ ! -e nezha-agent ]; then
    URL=\$(wget -qO- "https://api.github.com/repos/nezhahq/agent/releases/latest" | grep -o "https.*linux_amd64.zip")
    URL=\${URL:-https://github.com/nezhahq/agent/releases/download/v0.15.6/nezha-agent_linux_amd64.zip}
    wget \${URL}
    unzip -qod ./ nezha-agent_linux_amd64.zip
    rm -f nezha-agent_linux_amd64.zip
  fi
}

check_run
check_variable
download_agent
EOF
}

generate_pm2_file() {
TLS=${NEZHA_TLS:+'--tls'}
cat > ecosystem.config.js << EOF
module.exports = {
"apps":[
      {
          "name":"web",
          "script":"/app/web.js run"
      },
      {
          "name":"nezha",
          "script":"/app/nezha-agent",
          "args":"-s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} ${TLS}"
EOF
  cat >> ecosystem.config.js << EOF
      }
  ]
}
EOF
}

generate_pm2_file
generate_nezha

[ -e nezha.sh ] && bash nezha.sh
[ -e ecosystem.config.js ] && pm2 start

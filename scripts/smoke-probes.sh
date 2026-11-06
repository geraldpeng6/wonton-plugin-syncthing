# Syncthing：sso=proxy，网关加 X-API-Key（核心生成的密钥，等于用户的凭据）；清单没有 mcp。
# shellcheck shell=bash disable=SC2034
# 应用没有“用户”概念，认的是这把只属于用户的密钥。

web_assert() { grep -qi 'syncthing'; }   # 标准输入：应用真实页面

identity_check() { # 自己的 REST 接口：网关带上用户的 API key 才 200，且返回本机身份
  local st mine anon
  st="$(web_get /rest/system/status -H 'Accept: application/json')" || { echo "/rest/system/status 失败：$st"; return 1; }
  mine="$(jq -r '.myID // empty' <<<"$st")"
  [[ "$mine" =~ ^[A-Z0-9-]{10,}$ ]] || { echo "status 没有 myID：$st"; return 1; }
  # 同一接口不带会话要被拒
  anon="$(curl -sS --noproxy '*' -o /dev/null -w '%{http_code}' "$SMOKE_WEB_URL/rest/system/status")"
  [[ "$anon" != 200 ]] || { echo "匿名 /rest/system/status 也是 200"; return 1; }
}

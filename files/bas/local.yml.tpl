ability_refresh: 60
api_key_blue: ${api_key_blue} 
api_key_red: ${api_key_red} 
app.contact.dns.domain: mycaldera.caldera
app.contact.dns.socket: 0.0.0.0:8853
app.contact.ftp.host: 0.0.0.0
app.contact.ftp.port: 2222
app.contact.ftp.pword: caldera
app.contact.ftp.server.dir: ftp_dir
app.contact.ftp.user: caldera_user
app.contact.gist: API_KEY
app.contact.html: /weather
app.contact.http: http://0.0.0.0:${caldera_port}
app.contact.slack.api_key: SLACK_TOKEN
app.contact.slack.bot_id: SLACK_BOT_ID
app.contact.slack.channel_id: SLACK_CHANNEL_ID
app.contact.tcp: 0.0.0.0:7010
app.contact.tunnel.ssh.host_key_file: REPLACE_WITH_KEY_FILE_PATH
app.contact.tunnel.ssh.host_key_passphrase: REPLACE_WITH_KEY_FILE_PASSPHRASE
app.contact.tunnel.ssh.socket: 0.0.0.0:8022
app.contact.tunnel.ssh.user_name: sandcat
app.contact.tunnel.ssh.user_password: s4ndc4t!
app.contact.udp: 0.0.0.0:7011
app.contact.websocket: 0.0.0.0:7012
auth.login.handler.module: default
crypt_salt: bdNIXnxObg-Drt5c8kU8asRDHOK8gvpnutAZU6EXyJU
encryption_key: frt_iU50LIBkLYxQURap2q-2yWb8JOKrbyd2-zk5-Og
exfil_dir: /tmp/caldera
host: 0.0.0.0
objects.planners.default: atomic
plugins:
- access
- atomic
- compass
- debrief
- fieldmanual
- manx
- response
- sandcat
- stockpile
- training
port: ${caldera_port} 
reports_dir: /tmp
requirements:
  go:
    command: go version
    type: installed_program
    version: 1.11
  python:
    attr: version
    module: sys
    type: python_module
    version: 3.8.0
users:
  blue:
    ${blue_username}: ${blue_password} 
  red:
    ${caldera_admin_username}: ${caldera_admin_password} 
    ${red_username}: ${red_password} 

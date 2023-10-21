[Unit]
Description=Prelude Operator Headless
After=network.target

[Service]
ExecStart=/opt/prelude/headless --accountEmail=${operator_email} --sessionToken=${token}
Restart=always

[Install]
WantedBy=multi-user.target

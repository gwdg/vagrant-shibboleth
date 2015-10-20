sudo tee /opt/shibboleth-idp/edit-webapp/WEB-INF/classes/logging.properties <<EOF
org.apache.catalina.core.ContainerBase.[Catalina].level = INFO
org.apache.catalina.core.ContainerBase.[Catalina].handlers = java.util.logging.ConsoleHandler
EOF


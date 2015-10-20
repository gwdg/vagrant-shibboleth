#!/bin/bash
TMPFILE=/tmp/TestJCE
cat <<EOF >${TMPFILE}.java
import javax.crypto.Cipher;
public class TestJCE {
 
    public static void main(String[] args) {
        try {
            System.out.println("Testing Cipher.getMaxAllowedKeyLength(\"AES\")...");
            int maxKeyLen = Cipher.getMaxAllowedKeyLength("AES");
            System.out.println("Keylength: " + maxKeyLen);
            if (maxKeyLen <=128) {
                System.out.println("Missing JCE.");
                return;
            }
            if (maxKeyLen < 2147483647) {
                System.out.println("JCE not fully functional (<2147483647)");
            } else {
                System.out.println("JCE OK");
            }
        } catch (Exception e) {
            System.out.println("Exception: " + e);
        }
    }
}
EOF
 
JAVA=java
if [ -n "$JAVA_HOME" ]; then
        if [ -f "$JAVA_HOME/bin/java" ]; then
                JAVA=$JAVA_HOME/bin/java
        else
                echo "JAVA_HOME=$JAVA_HOME not set correctly. Abort."
                exit 1
        fi
fi
${JAVA}c ${TMPFILE}.java
$JAVA -version
cd `dirname ${TMPFILE}`
$JAVA `basename ${TMPFILE}`
rm -f ${TMPFILE}.java ${TMPFILE}.class


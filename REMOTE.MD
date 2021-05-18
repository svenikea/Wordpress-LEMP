* Create a Certificate Authority

```
echo 01 | sudo tee ca.srl
sudo openssl genrsa -des3 -out ca-key.pem
sudo openssl req -new -x509 -days 365 -key ca-key.pem -out ca.pem
```

* Create a server certificate signing request and key

> Generating a private key
```
sudo openssl genrsa -des3 -out server-key.pem
```

> Creating a CA certificate

```
sudo openssl req -new -x509 -days 365 -key ca-key.pem -out ca.pem
```

* Create a server certificate signing request and key

> Creating a server key

```
sudo openssl genrsa -des3 -out server-key.pem
```
> Creating our server CSR

```
sudo openssl req -new -key server-key.pem -out server.csr
```

> Connect via IP address
> Replacing x.x.x.x with the IP address(es) of your Docker daemon

```
echo subjectAltName = IP:x.x.x.x,IP:127.0.0.1 > extfile.cnf
```

> Signing our CSR

```
sudo openssl x509 -req -days 365 -in server.csr -CA ca.pem \
-CAkey ca-key.pem -out server-cert.pem -extfile extfile.cnf
```

> Removing the passphrase from the server key

```
sudo openssl rsa -in server-key.pem -out server-key.pem
```

> Securing the key and certificate on the Docker server

```
sudo chmod 0600 server-key.pem server-cert.pem ca.pem
```

* Configuring the Docker daemon

> Enabling Docker TLS on systemd (Optional)

```
ExecStart=/usr/bin/docker -d -H tcp://<VM_IP_Address>:<Random_Port> --tlsverify --
tlscacert=<ca.pem File_location> --tlscert=<server-cert.pem File_location> --tlskey=<server-key.pem File_location>
```

> Reloading and restarting the Docker daemon

```
sudo systemctl --system daemon-reload
```
> Using Docker Daemon from config file (Optional)

```
{
	"debug" : true,
	"hosts" : ["tcp://<VM_IP_Address>:<Random_Port>", "unix:///var/run/docker.sock"],
	"experimental" : true,
	"log-driver" : "json-file",
	"log-opts" : {
		"max-size" : "20m",
		"max-file" : "3",
		"labels" : "develope_status",
		"env" : "developing"
	}
}
```

> Start the Dockerd daemon

```
sudo dockerd --selinux-enabled
```

* Creating a client certificate and key

> Creating a client key

```
sudo openssl genrsa -des3 -out client-key.pem
```

> Creating a client CSR

```
sudo openssl req -new -key client-key.pem -out client.csr
```

> Adding Client Authentication attributes

```
echo extendedKeyUsage = clientAuth > extfile.cnf
```

> Signing our client CSR

```
sudo openssl x509 -req -days 365 -in client.csr -CA ca.pem \
-CAkey ca-key.pem -out client-cert.pem -extfile extfile.cnf
```

> Stripping out the client key pass phrase

```
sudo openssl rsa -in client-key.pem -out client-key.pem
```

* Configuring our Docker client for authentication

> Copying the key and certificate on the Docker client

```
mkdir -p ~/.docker/ \
&& cp ca.pem ~/.docker/ca.pem \
&& cp client-key.pem ~/.docker/key.pem \
&& cp client-cert.pem ~/.docker/cert.pem \
&& chmod 0600 ~/.docker/key.pem ~/.docker/cert.pem
```

* Testing TLS-authenticated connection

> With ```--tslverify``` argument to connect with TLS

```
sudo docker -H=<VM_IP_Address>:<Random_Port> --tlsverify info
```

> Without ```--tslverify``` argument it would return 

```
Error response from daemon: Client sent an HTTP request to an HTTPS server.
```

> Which mean that everything worked 


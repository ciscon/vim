import errno
import queue
import socket
import sys
import threading
import time
import asyncio
import xml.etree.ElementTree as ET

from . import log


class ConnectionHandler:
    """Handles read and write operations to a given socket."""

    def __init__(self, socket, address):
        """Accept the socket used for reading and writing.

        socket -- the network socket
        """
        self.sock = socket
        self.address = address

    def __del__(self):
        """Make sure the connection is closed."""
        self.close()

    def isconnected(self):
        return 1

    def close(self):
        """Close the connection."""
        log.Log("Closing the socket", log.Logger.DEBUG)
        self.sock.close()

    def __recv_length(self):
        """Get the length of the proceeding message."""
        length = []
        while 1:
            c = self.sock.recv(1)
            if c == b'':
                self.close()
                raise EOFError('Socket Closed')
            if c == b'\x00':
                return int(b''.join(length))
            if c.isdigit():
                length.append(c)

    def __recv_null(self):
        """Receive a null byte."""
        while 1:
            c = self.sock.recv(1)
            if c == b'':
                self.close()
                raise EOFError('Socket Closed')
            if c == b'\x00':
                return

    def __recv_body(self, to_recv):
        body = []
        while to_recv > 0:
            buf = self.sock.recv(to_recv)
            if buf == b'':
                self.close()
                raise EOFError('Socket Closed')
            to_recv -= len(buf)
            body.append(buf.decode("utf-8"))
        return ''.join(body)

    def recv_msg(self):
        """Receive a message from the debugger.

        Returns a string, which is expected to be XML.
        """
        length = self.__recv_length()
        body = self.__recv_body(length)
        self.__recv_null()
        return body

    def send_msg(self, cmd):
        """Send a message to the debugger.

        cmd -- command to send
        """
        # self.sock.send(cmd + '\0')
        MSGLEN = len(cmd)
        totalsent = 0
        while totalsent < MSGLEN:
            sent = self.sock.send(bytes(cmd[totalsent:].encode()))
            if sent == 0:
                raise RuntimeError("socket connection broken")
            totalsent = totalsent + sent
        sent = self.sock.send(b'\x00')


class SocketCreator:

    def __init__(self, input_stream=None):
        """Create a new Connection.

        The connection is not established until open() is called.

        input_stream -- object for checking input stream and user interrupts (default None)
        """
        self.__sock = None
        self.input_stream = input_stream
        self.proxy_success = False

    def start(self, host='', proxy_host = '', proxy_port = 9001, idekey = None, port=9000, timeout=30):
        """Listen for a connection from the debugger. Listening for the actual
        connection is handled by self.listen()

        host -- host name where debugger is running (default '')
        port -- port number which debugger is listening on (default 9000)
        proxy_host -- If using a DBGp Proxy, host name where the proxy is running (default None to disable)
        proxy_port -- If using a DBGp Proxy, port where the proxy is listening for debugger connections (default 9001)
        idekey -- The idekey that our Api() wrapper is expecting. Only required if using a proxy
        timeout -- time in seconds to wait for a debugger connection before giving up (default 30)
        """
        print('Waiting for a connection (Ctrl-C to cancel, this message will '
              'self-destruct in ', timeout, ' seconds...)')
        serv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            serv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            serv.setblocking(1)
            serv.bind((host, port))
            serv.listen(5)
            if proxy_host and proxy_port:
                # Register ourselves with the proxy server
                self.proxyinit(proxy_host, proxy_port, port, idekey)
            self.__sock = self.accept(serv, timeout)
        except socket.timeout:
            raise TimeoutError("Timeout waiting for connection")
        finally:
            self.proxystop(proxy_host, proxy_port, idekey)
            serv.close()

    def accept(self, serv, timeout):
        """Non-blocking listener. Provides support for keyboard interrupts from
        the user. Although it's non-blocking, the user interface will still
        block until the timeout is reached.

        serv -- Socket server to listen to.
        timeout -- Seconds before timeout.
        """
        start = time.time()
        while True:
            if (time.time() - start) > timeout:
                raise socket.timeout
            try:
                """Check for user interrupts"""
                if self.input_stream is not None:
                    self.input_stream.probe()
                return serv.accept()
            except socket.error:
                pass

    def clear(self):
        self.__sock = None

    def socket(self):
        return self.__sock

    def has_socket(self):
        return self.__sock is not None

    def proxyinit(self, proxy_host, proxy_port, port, idekey):
        """Register ourselves with the proxy."""
        if not proxy_host or not proxy_port:
            return

        self.log("Connecting to DBGp proxy [%s:%d]" % (proxy_host, proxy_port))
        proxy_conn = socket.create_connection((proxy_host, proxy_port), 30)

        self.log("Sending proxyinit command")
        msg = 'proxyinit -p %d -k %s -m 0' % (port, idekey)
        proxy_conn.send(msg.encode())
        proxy_conn.shutdown(socket.SHUT_WR)

        # Parse proxy response
        response = proxy_conn.recv(8192)
        proxy_conn.close()
        response = ET.fromstring(response)
        self.proxy_success = bool(response.get("success"))

    def proxystop(self, proxy_host, proxy_port, idekey):
        """De-register ourselves from the proxy."""
        if not self.proxy_success:
            return

        proxy_conn = socket.create_connection((proxy_host, proxy_port), 30)

        self.log("Sending proxystop command")
        msg = 'proxystop -k %s' % str(idekey)
        proxy_conn.send(msg.encode())
        proxy_conn.close()
        self.proxy_success = False



class BackgroundSocketCreator(threading.Thread):

    def __init__(self, host, port, proxy_host, proxy_port, idekey, output_q):
        self.__output_q = output_q
        self.__host = host
        self.__port = port
        self.__proxy_host = proxy_host
        self.__proxy_port = proxy_port
        self.__idekey = idekey
        self.proxy_success = False
        self.__socket_task = None
        self.__loop = None
        threading.Thread.__init__(self)

    @staticmethod
    def log(message):
        log.Log(message, log.Logger.DEBUG)

    def run(self):
        # needed for python 3.5
        self.__loop = asyncio.new_event_loop()
        asyncio.set_event_loop(self.__loop)
        self.__loop.run_until_complete(self.run_async())

    async def run_async(self):
        self.log("Started")
        self.log("Listening on port %s" % self.__port)
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.setblocking(False)
            s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            s.bind((self.__host, self.__port))
            s.listen(5)
            while 1:
                try:
                    # using ensure_future here since before 3.7, this is not a coroutine, but returns a future
                    self.__socket_task = asyncio.ensure_future(self.__loop.sock_accept(s))
                    if self.__proxy_host and self.__proxy_port:
                        # Register ourselves with the proxy server
                        await self.proxyinit()
                    client, address = await self.__socket_task
                    # set resulting socket to blocking
                    client.setblocking(True)

                    self.log("Found client, %s" % str(address))
                    self.__output_q.put((client, address))
                    break
                except socket.error:
                    await self.proxystop()
                    # No connection
                    pass
        except socket.error as socket_error:
            self.log("Error: %s" % str(sys.exc_info()))
            self.log("Stopping server")

            if socket_error.errno == errno.EADDRINUSE:
                self.log("Address already in use")
                print("Socket is already in use")
        except asyncio.CancelledError as e:
            self.log("Stopping server")
            self.__socket_task = None
        except Exception as e:
            print("Exception caught")
            self.log("Error: %s" % str(sys.exc_info()))
            self.log("Stopping server")
        finally:
            await self.proxystop()
            self.log("Finishing socket server")
            s.close()

    async def proxyinit(self):
        """Register ourselves with the proxy."""
        if not self.__proxy_host or not self.__proxy_port:
            return

        self.log("Connecting to DBGp proxy [%s:%d]" % (self.__proxy_host, self.__proxy_port))
        proxy_conn = socket.create_connection((self.__proxy_host, self.__proxy_port), 30)

        self.log("Sending proxyinit command")
        msg = 'proxyinit -p %d -k %s -m 0' % (self.__port, self.__idekey)
        proxy_conn.send(msg.encode())
        proxy_conn.shutdown(socket.SHUT_WR)

        # Parse proxy response
        response = proxy_conn.recv(8192)
        proxy_conn.close()
        response = ET.fromstring(response)
        self.proxy_success = bool(response.get("success"))

    async def proxystop(self):
        """De-register ourselves from the proxy."""
        if not self.proxy_success:
            return

        proxy_conn = socket.create_connection((self.__proxy_host, self.__proxy_port), 30)

        self.log("Sending proxystop command")
        msg = 'proxystop -k %s' % str(self.__idekey)
        proxy_conn.send(msg.encode())
        proxy_conn.close()
        self.proxy_success = False



    def _exit(self):
        if self.__socket_task:
            # this will raise asyncio.CancelledError
            self.__socket_task.cancel()

    # called from outside of the thread
    def exit(self):
        self.__loop.call_soon_threadsafe(self._exit)


class SocketServer:

    def __init__(self):
        self.__socket_q = queue.Queue(1)
        self.__thread = None

    def __del__(self):
        self.stop()

    def start(self, host, port, proxy_host, proxy_port, ide_key):
        if not self.is_alive():
            self.__thread = BackgroundSocketCreator(
                host, port, proxy_host, proxy_port, ide_key, self.__socket_q)
            self.__thread.start()

    def is_alive(self):
        return self.__thread and self.__thread.is_alive()

    def has_socket(self):
        return self.__socket_q.full()

    def socket(self):
        return self.__socket_q.get_nowait()

    def stop(self):
        if self.is_alive():
            self.__thread.exit()
            self.__thread.join(3000)
        if self.has_socket():
            self.socket()[0].close()

import functools
import http.server
import pathlib
import tempfile
import threading
import unittest
import shutil
import subprocess

ROOT = pathlib.Path(__file__).parent.absolute()

WCURL_PATH = ROOT / '..' / 'wcurl'
DATA_PATH = ROOT / 'integration-data'


class TestWcurl(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        handler = functools.partial(
            http.server.SimpleHTTPRequestHandler,
            directory=DATA_PATH,
        )

        cls.server_addr = '127.0.0.1'
        cls.server_port = 9080

        cls._server = http.server.ThreadingHTTPServer(
            (cls.server_addr, cls.server_port),
            handler
        )

        def run_server():
            cls._server.serve_forever()

        cls._server_thread = threading.Thread(target=run_server)
        cls._server_thread.start()

    @classmethod
    def tearDownClass(cls):
        cls._server.shutdown()
        cls._server_thread.join(timeout=1)

        if cls._server_thread.is_alive():
            raise RuntimeException('Server thread timed out')

    def setUp(self):
        self.dir = tempfile.mkdtemp(prefix='wcurl_')
        self.path = pathlib.Path(self.dir)
        print(f'Using temporary directory: {self.dir}')

    def url_for(self, path):
        return f'http://{self.server_addr}:{self.server_port}/{path}'

    def exec_wcurl(self, *options, check=True):
        result = subprocess.run(
            args=[WCURL_PATH, *options],
            cwd=self.dir,
            capture_output=True,
            check=check,
        )

        return result

    def test_single_url(self):
        result = self.exec_wcurl(self.url_for('1.txt'))
        files = sorted(p.name for p in self.path.glob('*'))
        self.assertEqual(files, ['1.txt'])

    def test_repeated_url(self):
        url = self.url_for('1.txt')
        result = self.exec_wcurl(url, url)
        files = sorted(p.name for p in self.path.glob('*'))
        self.assertEqual(files, ['1.txt', '1.txt.1'])

    def test_fail_exits_with_error(self):
        url = self.url_for('does-not-exist')
        with self.assertRaises(subprocess.CalledProcessError):
            self.exec_wcurl(url)

if __name__ == '__main__':
    unittest.main()

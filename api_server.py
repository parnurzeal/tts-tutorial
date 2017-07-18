from flask import Flask
from gcloud import storage
import sys
import optparse
import time
import tarfile

app = Flask(__name__)

start = int(round(time.time()))

@app.route("/")
def hello_world():

    return "Hello world from Docker!"

@app.route("/create")
def create_storage():
    client = storage.Client()
    bucket = client.get_bucket('nemo-pipeline')
    blob = bucket.blob('my-test-file.txt')
    blob.upload_from_string('this is a test content!')
    return 'finish writing to file'

def download_tarfile(blobfile):
    client = storage.Client()


def extract_file(filename):
    tf = tarfile.open(filename, 'r:gz')
    tf.extractall('/tmp/voice')
    tf.close()

def tts(text):
    return ""

if __name__ == '__main__':
    parser = optparse.OptionParser(usage="python simpleapp.py -p ")
    parser.add_option('-p', '--port', action='store', dest='port', help='The port to listen on.')
    parser.add_option('-t', '--tarfile', action='store', dest='tarfile', help='The voice model in .tar.gz.')
    (args, _) = parser.parse_args()
    if args.port == None:
        print "Missing required argument: -p/--port"
        sys.exit(1)
    if args.tarfile == None:
        print "Missing required voice model tarfile: -t/--tarfile"
    #extract_file(args.tarfile)
    app.run(host='0.0.0.0', port=int(args.port), debug=False)

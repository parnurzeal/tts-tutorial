from flask import Flask
import flask
from gcloud import storage
import subprocess
import sys
import os
import logging
import optparse
import time
import tarfile

app = Flask(__name__)

start = int(round(time.time()))

VOICE_TAR = '/tmp/voice.tar.gz'
VOICE_FOLDER = '/tmp/voice'

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

def setup_voice(blobfile):
    # Split bucket name and path
    # assume it is always in the form of gs://<bucket>/../../../..
    split_path = blobfile.split('/', 3)
    bucket_name = split_path[2]
    filepath = split_path[3]

    client = storage.Client()
    bucket = client.get_bucket(bucket_name)
    blob = bucket.get_blob(filepath)
    dest = VOICE_TAR
    blob.download_to_filename(dest)
    extract_file(dest)

def extract_file(filename):
    tf = tarfile.open(filename, 'r:gz')
    tf.extractall(VOICE_FOLDER)
    tf.close()

@app.route('/tts/<string:text>')
def tts(text):
    #cmd = 'echo "hello"'
    #os.system(cmd)
    print text
    cmd = 'echo ' + text + ' | '
    cmd += '${FESTIVALDIR}/bin/text2wave '
    cmd += '-eval festvox/goog_en-SG_unison_cg.scm '
    cmd += '-eval "(voice_goog_en-SG_unison_cg)"'
    p = subprocess.Popen(cmd, cwd=VOICE_FOLDER, shell=True,
                         stdout=subprocess.PIPE)
    def read_process():
        for c in iter(lambda: p.stdout.read(1), ''):
            yield c
    print p
    return flask.Response(read_process(), mimetype='audio/wav')

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
    setup_voice(args.tarfile)
    app.logger.addHandler(logging.StreamHandler(sys.stdout))
    app.logger.setLevel(logging.DEBUG)

    app.run(host='0.0.0.0', port=int(args.port), debug=False)

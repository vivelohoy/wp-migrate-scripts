# Set environment variables to secrets:
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
from os import environ
import logging
import boto

BUCKET_NAME = 'wpmedia.vivelohoy.com'

if 'AWS_ACCESS_KEY_ID' not in environ or 'AWS_SECRET_ACCESS_KEY' not in environ:
	print 'Error: Environment variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY not set.'
	exit(1)

boto.set_file_logger('boto-copier', 's3_copy.log', logging.INFO)

s3 = boto.connect_s3()
bucket = s3.get_bucket(BUCKET_NAME)

for src_key in bucket.list():
	if 'wp-content/' not in src_key.name:
		new_key = 'wp-content/' + src_key.name
		src_key.copy(BUCKET_NAME, new_key)
		print '{src} => {dest}'.format(src=src_key.name, dest=new_key)
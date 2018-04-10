# Demo code for S3-based Voldemort configuration

Demonstrates the code that generates a configuration file and uploads to S3, prior to deploying the cluster in AWS.

The `docs/s3-example.ipynb` can be run interactively using Jupyter, with:

    $ jupyter notebook
    
and opening it in the browser at `http://localhost:8888`.

## Rendered output

```python
import boto3
import jinja2
import os
import time


s3_client = boto3.client('s3')

jinja_env = jinja2.Environment(loader=jinja2.FileSystemLoader('../templates/voldemort'))
```

### Manage Buckets

List all existing buckets


```python
response = s3_client.list_buckets()
bucket_names = []
if 'Buckets' in response:
    for bucket in response['Buckets']:
        bucket_names.append(bucket['Name'])
        
print(bucket_names)
```

    ['cf-templates-ug0jprpbbar6-us-west-1', 'cloudtrail-023262102897', 'phl-recent', 'voldemort', 'wishlist-aws']


Check if the bucket already exists, if not create it; then list all the files in it:


```python
CLUSTER = 'userdetails-aws'

if not CLUSTER in bucket_names:
    response = s3_client.create_bucket(
        Bucket=CLUSTER,
        CreateBucketConfiguration={
            'LocationConstraint': 'us-west-1'
        }
    )
    print("`{}` created".format(CLUSTER))
else:
    print("`{}` already exists".format(CLUSTER))

s3 = boto3.resource('s3')
bucket = s3.Bucket(CLUSTER)

for obj in bucket.objects.all():
    print(obj.key)
```

    `userdetails-aws` created


### Upload a file to the Bucket


```python
# Let's render the cluster.xml file first
filename = '{cluster}.xml'.format(cluster=CLUSTER)

template = jinja_env.get_template('cluster.xml')

prefix = 'node'
domain = 'aws.itunes.apple.com'
nodes = 7

render = template.render(
        hostname_prefix=prefix,
        cluster=CLUSTER,
        hosted_zone=domain,
        number_of_nodes=nodes,
        partitions=4,
        now=time.ctime()
)

tmpfile = os.path.join('/tmp', filename)
with open(tmpfile, 'wt') as dest:
    dest.write(render)
    
print(render[:900], ' ...', '\n\nSaved at:', tmpfile)
```

    <!-- Voldemort Cluster configuration file
         Created 2017-06-29, M. Massenzio (mmassenzio@apple.com)
    
         Cluster: userdetails-aws
         Configuration file rendered at Thu Jun 29 17:00:21 2017
         Deployed in Hosted Zone: aws.itunes.apple.com
         Nodes: 7
         Partitions per node: 4
    
         For more info see: https://github.pie.apple.com/its-infra/pegasus
      -->
    
    <cluster>
        <name>userdetails-aws</name>
        
        <server>
            <id>0</id>
            <host>node0.userdetails-aws.aws.itunes.apple.com</host>
            <http-port>8081</http-port>
            <socket-port>6666</socket-port>
            <partitions>0,7,14,21</partitions>
        </server>
        
        <server>
            <id>1</id>
            <host>node1.userdetails-aws.aws.itunes.apple.com</host>
            <http-port>8081</http-port>
            <socket-port>6666</socket-port>
            <partitions>1,8,15,22</partitions>
        </server>
        
        <server>
          ... 
    
    Saved at: /tmp/userdetails-aws.xml



```python
def ProgressCallable(object):
    def __init__(self, filename):
        self.filename = filename
        
    def __call__(self, bytescount):
        print("{} uploaded: {}".format(self.filename, bytescount))

        
bucket.upload_file(Filename=tmpfile, Key='cluster.xml', Callback=ProgressCallable(filename))
```

Verify the file is there:


```python
for obj in bucket.objects.all():
    if obj.key == 'cluster.xml':
        break
else:
    print("File not found")
```

Finally add the other "statically" defined files for the server and store properties:


```python
base_dir = os.path.join("..", "containers", "voldemort", CLUSTER)

if not os.path.exists(base_dir):
    raise ValueError("Folder {} missing".format(base_dir))

for ff in ['stores.xml', 'server.properties']:
    bucket.upload_file(Filename=os.path.join(base_dir, ff), Key=ff, Callback=ProgressCallable(ff))

# Finally, let's check all is well:
uploaded_files = []
for obj in bucket.objects.all():
    uploaded_files.append(obj.key)
    
for ff in ['stores.xml', 'server.properties', 'cluster.xml']:
    assert ff in uploaded_files
```

### Clean up

Once done with the exercise, remove the bucket, so it can be used again:


```python
objects_to_delete={'Objects': [{ 'Key': fname } for fname in uploaded_files]}

response = bucket.delete_objects(Delete=objects_to_delete)
if 'Errors' in response:
    print(response['Errors'])
else:
    response = bucket.delete()
    print(response.get('Errors', "No errors"))
```

    No errors


import kopf
import kubernetes.client
from kubernetes.client.rest import ApiException
import logging
import time

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configure Kubernetes client
configuration = kubernetes.client.Configuration()
kubernetes.config.load_incluster_config()
core_api = kubernetes.client.CoreV1Api()
custom_api = kubernetes.client.CustomObjectsApi()

# Handler for namespace creation
@kopf.on.create('v1', 'namespaces')
def handle_namespace_create(name, meta, **kwargs):
    creation_timestamp = meta.get('creationTimestamp')
    namespace_tracker = {
        'apiVersion': 'example.com/v1',
        'kind': 'NamespaceTracker',
        'metadata': {
            'name': f"nstrack-{name}"
        },
        'spec': {
            'namespace': name
        },
        'status': {
            'creationTimestamp': creation_timestamp,
            'conditions': [{
                'type': 'NamespaceExists',
                'status': 'True',
                'lastTransitionTime': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
                'message': f'Namespace {name} exists'
            }]
        }
    }

    try:
        custom_api.create_cluster_custom_object(
            group='example.com',
            version='v1',
            plural='namespacetrackers',
            body=namespace_tracker
        )
        logger.info(f"Created NamespaceTracker for namespace {name}")
    except ApiException as e:
        logger.error(f"Error creating NamespaceTracker for {name}: {e}")

# Handler for namespace deletion
@kopf.on.delete('v1', 'namespaces')
def handle_namespace_delete(name, **kwargs):
    try:
        custom_api.delete_cluster_custom_object(
            group='example.com',
            version='v1',
            plural='namespacetrackers',
            name=f"nstrack-{name}"
        )
        logger.info(f"Deleted NamespaceTracker for namespace {name}")
    except ApiException as e:
        if e.status != 404:  # Ignore if already deleted
            logger.error(f"Error deleting NamespaceTracker for {name}: {e}")

# Handler for namespace updates
@kopf.on.update('v1', 'namespaces')
def handle_namespace_update(name, meta, **kwargs):
    creation_timestamp = meta.get('creationTimestamp')
    try:
        # Check if NamespaceTracker exists
        existing = custom_api.get_cluster_custom_object(
            group='example.com',
            version='v1',
            plural='namespacetrackers',
            name=f"nstrack-{name}"
        )
        # Update status
        custom_api.patch_cluster_custom_object_status(
            group='example.com',
            version='v1',
            plural='namespacetrackers',
            name=f"nstrack-{name}",
            body={
                'status': {
                    'creationTimestamp': creation_timestamp,
                    'conditions': [{
                        'type': 'NamespaceExists',
                        'status': 'True',
                        'lastTransitionTime': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
                        'message': f'Namespace {name} exists'
                    }]
                }
            }
        )
        logger.info(f"Updated NamespaceTracker for namespace {name}")
    except ApiException as e:
        if e.status == 404:
            # NamespaceTracker doesn't exist, create it
            handle_namespace_create(name=name, meta=meta, **kwargs)
        else:
            logger.error(f"Error updating NamespaceTracker for {name}: {e}")

# Handler for NamespaceTracker CR deletion (cleanup if manually deleted)
@kopf.on.delete('example.com', 'v1', 'namespacetrackers')
def handle_namespacetracker_delete(spec, name, **kwargs):
    namespace = spec.get('namespace')
    logger.info(f"NamespaceTracker {name} deleted, no further action needed for namespace {namespace}")